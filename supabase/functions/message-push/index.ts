import type { UUID } from "node:crypto";
import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";

const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req) => {
    try {
        const payload = await req.json();
        const message = payload.record;

        // Step 1: message의 user_id를 통하여 push_option을 확인하고, 해당 방에 있는 유저들의 user_id 가져오기
        const { data: participants, error: participantsError } = await supabase
            .from("room_participants")
            .select("user_id")
            .eq("room_id", message.room_id) // room_id 기준으로 가져옴
            .neq("user_id", message.user_id) // 메시지 보낸 사람 제외
            .eq("push_option", true); // push_option이 TRUE인 유저만 가져옴

        if (participantsError || !participants) {
            console.error(
                "Error fetching room participants:",
                participantsError,
            );
            return new Response("Error fetching room participants", {
                status: 500,
            });
        }

        // Extract user_ids directly
        let userIds = participants.map((p) => p.user_id);

        // Step 2: Filter out blocked users
        const { data: blockedUsers, error: blockedUsersError } = await supabase
            .from("blocked_users")
            .select("user_id")
            .eq("block_user_id", message.user_id);

        if (blockedUsersError) {
            console.error("Error fetching blocked users:", blockedUsersError);
            return new Response("Error fetching blocked users", {
                status: 500,
            });
        }

        const blockedUserIds = blockedUsers.map((b) => b.user_id);
        userIds = userIds.filter((id) => !blockedUserIds.includes(id));

        // Step 3: profiles 테이블에서 fcm_token 가져오기
        const { data: profiles, error: profilesError } = await supabase
            .from("profiles")
            .select("id, fcm_token") // ✅ fcm_token만 조회
            .in("id", userIds);

        if (profilesError) {
            console.error("Error fetching user profiles:", profilesError);
            return new Response("Error fetching user profiles", {
                status: 500,
            });
        }

        // fcm_token이 존재하는 유저만 필터링
        const fcmTokens = profiles
            .map((p) => p.fcm_token)
            .filter((token) => !!token); // ✅ fcm_token이 NULL이 아닌 경우만 필터링

        // Step 4: Get room_name for title and set body based on message type
        const { data: room, error: roomError } = await supabase
            .from("rooms")
            .select("room_name")
            .eq("id", message.room_id)
            .single(); // room_id로 room_name 가져오기

        if (roomError || !room) {
            console.error("Error fetching room name:", roomError);
            return new Response("Error fetching room name", { status: 500 });
        }

        // 메시지 타입에 따라 body 설정
        const body = message.type === "textMessage" ? message.content : "사진";
        const title = room.room_name; // ✅ room_name을 title로 사용

        // Step 1: message의 user_id를 통하여 push_option을 확인하고, 해당 방에 있는 유저들의 user_id 가져오기
        const { data: userNicknameData, error: userNicknameDataError } =
            await supabase
                .from("profiles")
                .select("nickname")
                .eq("id", message.user_id)
                .single(); // Ensures we get a single record

        if (!userNicknameData || userNicknameDataError) {
            console.error(
                "Error fetching userNickname:",
                userNicknameDataError,
            );
            return new Response("Error fetching userNickname", {
                status: 500,
            });
        }

        // Safely extract the `nickname` from the returned data
        const userNickname: string = userNicknameData.nickname || ""; // Access `nickname` property directly

        // Step 4: Send FCM notifications in batch

        const accessToken = await getAccessToken({
            clientEmail: Deno.env.get("client_email")!,
            privateKey: Deno.env.get("private_key")!.replace(/\\n/g, "\n"),
        });

        // 테스팅
        console.log(`fcmTokens: ${JSON.stringify(fcmTokens)}`);
        console.log(`title: ${title}`);
        console.log(`body: ${body}`);
        console.log(`accessToken: ${accessToken}`);
        console.log(`room_id: ${message.room_id}`);
        console.log(`participants: ${JSON.stringify(participants)}`);
        console.log(`message.type: ${message.type}`);
        console.log(`message.content: ${message.content}`);
        console.log(`userNickname: ${userNickname}`);

        // 배치 요청을 위해 한 번의 요청으로 여러 메시지를 보냄
        await sendBatchNotification(
            fcmTokens,
            title,
            body,
            accessToken,
            message.room_id,
            participants,
            userNickname,
        );

        return new Response("Notifications sent successfully", { status: 200 });
    } catch (error) {
        console.error("Unexpected error:", error);
        return new Response("Internal Server Error", { status: 500 });
    }
});

async function sendBatchNotification(
    fcmTokens: string[],
    title: string,
    body: string,
    accessToken: string,
    roomId: string,
    participants: {
        user_id: UUID;
    }[],
    userNickname: string,
) {
    if (fcmTokens.length === 0) {
        console.log("No FCM tokens to send notifications to.");
        return;
    }

    // 500개 이하의 토큰을 그룹화하여 한 번에 전송
    const tokenGroups = [];
    while (fcmTokens.length > 0) {
        tokenGroups.push(fcmTokens.splice(0, 500));
    }

    for (const tokens of tokenGroups) {
        const requests = tokens.map(async (token) => {
            const messagePayload = {
                message: {
                    token,
                    notification: {
                        title,
                        body, // messages의 content
                    },
                    data: {
                        roomId,
                        userNickname,
                        content: body,
                        type: "message",
                    },
                },
            };

            try {
                const res = await fetch(
                    `https://fcm.googleapis.com/v1/projects/udaadaa/messages:send`,
                    {
                        method: "POST",
                        headers: {
                            "Content-Type": "application/json",
                            Authorization: `Bearer ${accessToken}`,
                        },
                        body: JSON.stringify(messagePayload),
                    },
                );
                if (!res.ok) {
                    console.error(
                        "Error sending notification:",
                        await res.text(),
                    );
                } else {
                    console.log(participants);
                }
            } catch (err) {
                return console.error("Fetch error:", err);
            }
        });

        // 병렬 요청 실행 (최대 500개씩)
        await Promise.all(requests);
    }
}

// Function to get the access token for FCM
function getAccessToken({
    clientEmail,
    privateKey,
}: {
    clientEmail: string;
    privateKey: string;
}) {
    const jwtClient = new JWT({
        email: clientEmail,
        key: privateKey,
        scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });

    return new Promise<string>((resolve, reject) => {
        jwtClient.authorize((err, tokens) => {
            if (err) {
                reject(err);
            } else {
                resolve(tokens!.access_token!);
            }
        });
    });
}
