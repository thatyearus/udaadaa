import { createClient } from "npm:@supabase/supabase-js@2";

// const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
// const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabaseUrl = "https://lfwyakzyyrsjdgqrkhsm.supabase.co";
const serviceKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxmd3lha3p5eXJzamRncXJraHNtIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNTI3OTQ5NCwiZXhwIjoyMDQwODU1NDk0fQ.SRpiEPdNnkO18iL8M__VwGM4qhx67Hjj7EY2lOPwXoY";
const supabase = createClient(supabaseUrl, serviceKey);

// --- Interfaces ---

interface BlockedUser {
    block_user_id: string;
}

interface BlockedMessage {
    message_id: string;
}

interface PushOption {
    push_option: boolean;
    room_id: string;
}

interface Profile {
    id: string;
    nickname: string;
    created_at: string;
    push_option: boolean;
    fcm_token: string | null;
}

interface Message {
    id: string;
    user_id: string;
    room_id: string;
    content: string | null;
    type: string;
    profiles?: Profile;
    created_at: string;
    image_path: string | null;
    chat_reactions?: Reaction[];
    read_receipts?: ReadReceipt[];
}

interface Reaction {
    id: string;
    room_id: string;
    message_id: string;
    user_id: string;
    content: string;
    created_at: string;
}

interface ReadReceipt {
    user_id: string;
}

interface Room {
    id: string;
    created_at: string;
    room_name: string;
    start_day: string | null;
    end_day: string | null;
    profiles: Profile[];
}

interface RoomParticipant {
    room_id: string;
    user_id: string;
}

// --- Helper Functions ---

async function fetchBlockedUsers(userId: string): Promise<string[]> {
    try {
        const { data, error } = await supabase
            .from("blocked_users")
            .select("block_user_id")
            .eq("user_id", userId);

        if (error) {
            console.error(`Error fetching blocked users: ${error.message}`);
            throw new Error(`Fetch Blocked Users Error: ${error.message}`);
        }

        return (data as BlockedUser[]).map((item) => item.block_user_id);
    } catch (error) {
        console.error(`Error in fetchBlockedUsers: ${error}`);
        throw error;
    }
}

async function fetchBlockedMessages(userId: string): Promise<string[]> {
    try {
        const { data, error } = await supabase
            .from("blocked_messages")
            .select("message_id")
            .eq("user_id", userId);

        if (error) {
            console.error(`Error fetching blocked messages: ${error.message}`);
            throw new Error(`Fetch Blocked Messages Error: ${error.message}`);
        }

        return (data as BlockedMessage[]).map((item) => item.message_id);
    } catch (error) {
        console.error(`Error in fetchBlockedMessages: ${error}`);
        throw error;
    }
}

async function fetchPushOptions(
    userId: string,
): Promise<Record<string, boolean>> {
    try {
        const { data, error } = await supabase
            .from("room_participants")
            .select("push_option, room_id")
            .eq("user_id", userId);

        if (error) {
            console.error(`Error fetching push options: ${error.message}`);
            throw new Error(`Fetch Push Options Error: ${error.message}`);
        }

        // Convert array to map of room_id -> push_option
        return (data as PushOption[]).reduce<Record<string, boolean>>(
            (acc, item) => {
                acc[item.room_id] = item.push_option;
                return acc;
            },
            {},
        );
    } catch (error) {
        console.error(`Error in fetchPushOptions: ${error}`);
        throw error;
    }
}

async function loadChatList(userId: string): Promise<any[]> {
    try {
        // First, get all room IDs where the user is a participant
        const { data: participantData, error: participantError } =
            await supabase
                .from("room_participants")
                .select("room_id")
                .eq("user_id", userId);

        if (participantError) {
            console.error(
                `Error fetching room participants: ${participantError.message}`,
            );
            throw new Error(
                `Fetch Room Participants Error: ${participantError.message}`,
            );
        }

        const roomIds = (participantData as RoomParticipant[]).map((item) =>
            item.room_id
        );

        if (roomIds.length === 0) {
            return []; // No rooms found
        }

        // Then, fetch all rooms with their profiles
        const { data, error } = await supabase
            .from("rooms")
            .select("*, profiles(*)")
            .in("id", roomIds);

        if (error) {
            console.error(`Error fetching rooms: ${error.message}`);
            throw new Error(`Fetch Rooms Error: ${error.message}`);
        }

        // Return raw data without processing
        return data || [];
    } catch (error) {
        console.error(`Error in loadChatList: ${error}`);
        throw error;
    }
}

// --- New Helper Function ---
async function fetchLatestMessagesForRooms(chatList: Room[]): Promise<Room[]> {
    console.log(`🔍 Fetching latest messages for ${chatList.length} rooms...`);
    try {
        const updatedChatList = await Promise.all(
            chatList.map(async (room) => {
                const { data: messageData, error: messageError } =
                    await supabase
                        .from("messages")
                        .select("*")
                        .eq("room_id", room.id)
                        .order("created_at", { ascending: false })
                        .limit(1)
                        .maybeSingle(); // Use maybeSingle to return null if no message

                if (messageError) {
                    console.error(
                        `❌ Error fetching latest message for room ${room.id}: ${messageError.message}`,
                    );
                    // Return room without last_message in case of error
                    return { ...room, last_message: null };
                }

                console.log(
                    `✅ Fetched latest message for room ${room.id}: ${
                        messageData ? messageData.id : "None"
                    }`,
                );
                // Attach the raw message data (or null) to the room object
                return { ...room, last_message: messageData };
            }),
        );
        console.log("✅ Successfully attached latest messages to chat list.");
        return updatedChatList;
    } catch (error) {
        console.error(`❌ Error in fetchLatestMessagesForRooms: ${error}`);
        // Return the original list if the Promise.all fails
        return chatList.map((room) => ({ ...room, last_message: null }));
    }
}

// --- Helper Function for Latest Read Receipts ---
async function fetchLatestReadReceipts(
    userId: string,
    roomIds: string[],
): Promise<Record<string, string | null>> {
    console.log(
        `🔍 Fetching latest read receipt for userId: ${userId} across ${roomIds.length} rooms (optimized)...`,
    );
    if (roomIds.length === 0) {
        console.log("⚠️ No room IDs provided, returning empty receipts map.");
        return {};
    }

    const resultsMap: Record<string, string | null> = {};

    try {
        // Create an array of Promises, one for each room query
        const receiptPromises = roomIds.map(async (roomId) => {
            try {
                const { data, error } = await supabase
                    .from("read_receipts")
                    .select("created_at") // Select only the timestamp
                    .eq("user_id", userId)
                    .eq("room_id", roomId)
                    .order("created_at", { ascending: false }) // Order by time descending
                    .limit(1) // Get only the latest one
                    .maybeSingle(); // Return null if no record found

                if (error) {
                    console.error(
                        `❌ Error fetching latest receipt for room ${roomId}: ${error.message}`,
                    );
                    return { roomId, createdAt: null }; // Return null on error for this room
                }

                if (data) {
                    console.log(
                        `✅ Found latest receipt for room ${roomId}: ${data.created_at}`,
                    );
                    return { roomId, createdAt: data.created_at };
                } else {
                    console.log(`- No receipt found for room ${roomId}`);
                    return { roomId, createdAt: null };
                }
            } catch (innerError) {
                console.error(
                    `❌ Unexpected error fetching receipt for room ${roomId}: ${innerError}`,
                );
                return { roomId, createdAt: null };
            }
        });

        // Wait for all individual room queries to complete
        const results = await Promise.all(receiptPromises);

        // Populate the map from the results array
        results.forEach((result) => {
            resultsMap[result.roomId] = result.createdAt;
        });

        console.log(`✅ Finished fetching latest read receipts.`);
        return resultsMap;
    } catch (error) {
        // Catch errors from Promise.all itself (less likely here)
        console.error(
            `❌ Error in fetchLatestReadReceipts Promise.all: ${error}`,
        );
        // Initialize map with nulls in case of top-level failure
        roomIds.forEach((id) => resultsMap[id] = null);
        return resultsMap;
    }
}

// --- Helper Function for Initial Messages ---
async function fetchInitialMessages(
    roomIds: string[],
    blockedUserIds: string[],
    blockedMessageIds: string[],
): Promise<Record<string, any[]>> {
    console.log(`🔍 Fetching initial messages for ${roomIds.length} rooms...`);
    if (roomIds.length === 0) {
        console.log(
            "⚠️ No room IDs provided, returning empty initial messages map.",
        );
        return {};
    }

    const initialMessagesMap: Record<string, any[]> = {};

    try {
        const messagePromises = roomIds.map(async (roomId) => {
            try {
                const { data, error } = await supabase
                    .from("messages")
                    .select(
                        "*, profiles!messages_user_id_fkey(*), chat_reactions(*), read_receipts(user_id)",
                    )
                    .eq("room_id", roomId)
                    .not("user_id", "in", `(${blockedUserIds.join(",")})`) // Use proper syntax for NOT IN
                    .not("id", "in", `(${blockedMessageIds.join(",")})`) // Use proper syntax for NOT IN
                    .order("created_at", { ascending: false })
                    .limit(20);

                if (error) {
                    console.error(
                        `❌ Error fetching initial messages for room ${roomId}: ${error.message}`,
                    );
                    return { roomId, messages: [] }; // Return empty array on error for this room
                }

                console.log(
                    `✅ Fetched ${
                        data?.length ?? 0
                    } initial messages for room ${roomId}`,
                );
                return { roomId, messages: data || [] };
            } catch (innerError) {
                console.error(
                    `❌ Unexpected error fetching initial messages for room ${roomId}: ${innerError}`,
                );
                return { roomId, messages: [] };
            }
        });

        const results = await Promise.all(messagePromises);

        // Populate the map from the results array
        results.forEach((result) => {
            initialMessagesMap[result.roomId] = result.messages;
        });

        console.log(`✅ Finished fetching initial messages.`);
        return initialMessagesMap;
    } catch (error) {
        console.error(`❌ Error in fetchInitialMessages Promise.all: ${error}`);
        // Initialize map with empty arrays in case of top-level failure
        roomIds.forEach((id) => initialMessagesMap[id] = []);
        return initialMessagesMap;
    }
}

// --- Helper Function for Initial IMAGE Messages ---
async function fetchInitialImageMessages(
    roomIds: string[],
    blockedUserIds: string[],
    blockedMessageIds: string[],
): Promise<Record<string, any[]>> {
    console.log(
        `🖼️ Fetching initial IMAGE messages for ${roomIds.length} rooms...`,
    );
    if (roomIds.length === 0) {
        console.log(
            "⚠️ No room IDs provided, returning empty initial image messages map.",
        );
        return {};
    }

    const initialImageMessagesMap: Record<string, any[]> = {};

    try {
        const messagePromises = roomIds.map(async (roomId) => {
            try {
                // Base query setup
                let query = supabase
                    .from("messages")
                    .select(
                        "*, profiles!messages_user_id_fkey(*), chat_reactions(*), read_receipts(user_id)",
                    )
                    .eq("room_id", roomId)
                    .not("image_path", "is", null) // <<<--- Only messages with images
                    .order("created_at", { ascending: false })
                    .limit(32); // <<<--- Limit to 32

                // Apply block filters if block lists are not empty
                if (blockedUserIds.length > 0) {
                    query = query.not(
                        "user_id",
                        "in",
                        `(${blockedUserIds.join(",")})`,
                    );
                }
                if (blockedMessageIds.length > 0) {
                    query = query.not(
                        "id",
                        "in",
                        `(${blockedMessageIds.join(",")})`,
                    );
                }

                const { data, error } = await query;

                if (error) {
                    console.error(
                        `❌ Error fetching initial image messages for room ${roomId}: ${error.message}`,
                    );
                    return { roomId, messages: [] }; // Return empty array on error
                }

                console.log(
                    `🖼️ Fetched ${
                        data?.length ?? 0
                    } initial IMAGE messages for room ${roomId}`,
                );
                return { roomId, messages: data || [] };
            } catch (innerError) {
                console.error(
                    `❌ Unexpected error fetching initial image messages for room ${roomId}: ${innerError}`,
                );
                return { roomId, messages: [] };
            }
        });

        const results = await Promise.all(messagePromises);

        // Populate the map from the results array
        results.forEach((result) => {
            initialImageMessagesMap[result.roomId] = result.messages;
        });

        console.log(`✅ Finished fetching initial image messages.`);
        return initialImageMessagesMap;
    } catch (error) {
        console.error(
            `❌ Error in fetchInitialImageMessages Promise.all: ${error}`,
        );
        // Initialize map with empty arrays in case of top-level failure
        roomIds.forEach((id) => initialImageMessagesMap[id] = []);
        return initialImageMessagesMap;
    }
}

// --- Helper Function for Unread Message Counts ---
async function calculateUnreadCounts(
    userId: string,
    latestReadReceipts: Record<string, string | null>, // 방 ID -> 마지막 읽은 UTC 타임스탬프 (ISO 문자열) 또는 null
    roomIds: string[], // 처리할 방 ID 목록
): Promise<Record<string, string[]>> { // Return type updated to only include unreadMessageIds
    console.log(
        `📊 Calculating unread messages for userId: ${userId} across ${roomIds.length} rooms...`,
    );
    const unreadMessagesByRoom: Record<string, string[]> = {};

    if (roomIds.length === 0) {
        console.log("⚠️ No room IDs provided, returning empty results.");
        return {};
    }

    // 각 방에 대한 쿼리를 병렬로 실행
    const countPromises = roomIds.map(async (roomId) => {
        const lastReadTimestamp = latestReadReceipts[roomId]; // 이미 UTC 타임스탬프 문자열 또는 null

        try {
            // 메시지 테이블에서 ID를 가져오는 쿼리 준비
            let query = supabase
                .from("messages")
                .select("id") // ID만 가져오도록 설정
                .eq("room_id", roomId)
                .neq("user_id", userId); // 자신이 보낸 메시지는 제외

            // 마지막 읽음 타임스탬프가 있으면, 해당 시간 이후의 메시지만 가져옴
            if (lastReadTimestamp) {
                query = query.gt("created_at", lastReadTimestamp); // UTC 타임스탬프 직접 비교
                console.log(
                    `   [Room: ${roomId}] Fetching messages after ${lastReadTimestamp}`,
                );
            } else {
                // 마지막 읽음 타임스탬프가 없으면, 해당 방의 모든 메시지 가져옴 (자신 제외)
                console.log(
                    `   [Room: ${roomId}] Fetching all messages (no last read receipt)`,
                );
            }

            // 쿼리 실행
            const { data, error } = await query;

            if (error) {
                console.error(
                    `❌ Error fetching unread messages for room ${roomId}: ${error.message}`,
                );
                return { roomId, unreadMessageIds: [] }; // 에러 발생 시 빈 배열로 처리
            }

            const unreadMessageIds = data?.map((message) => message.id) || []; // 메시지 ID 수집
            console.log(
                `   ✅ [Room: ${roomId}] Found ${unreadMessageIds.length} unread messages.`,
            );
            return { roomId, unreadMessageIds };
        } catch (innerError) {
            console.error(
                `❌ Unexpected error fetching unread messages for room ${roomId}: ${innerError}`,
            );
            return { roomId, unreadMessageIds: [] }; // 예외 발생 시 빈 배열로 처리
        }
    });

    // 모든 방의 쿼리가 완료될 때까지 대기
    const results = await Promise.all(countPromises);

    // 결과 취합
    results.forEach((result) => {
        unreadMessagesByRoom[result.roomId] = result.unreadMessageIds;
    });

    console.log("📊 Unread message IDs by room:", unreadMessagesByRoom);

    return unreadMessagesByRoom; // Only return unreadMessageIds
}

// --- Logging Helper Function ---
function logFetchedData(
    blocked_user_ids: string[],
    blocked_message_ids: string[],
    push_options: Record<string, boolean>,
    chat_list_data: any[],
) {
    console.log("\n--- 📊 Fetched Data Summary ---");

    // Log Blocked Users
    console.log("🚫 Blocked Users:", blocked_user_ids.length, "users");
    blocked_user_ids.forEach((id) => console.log(`  - Blocked user: ${id}`));

    // Log Blocked Messages
    console.log(
        "\n📵 Blocked Messages:",
        blocked_message_ids.length,
        "messages",
    );
    blocked_message_ids.forEach((id) =>
        console.log(`  - Blocked message: ${id}`)
    );

    // Log Push Options
    console.log(
        "\n🔔 Push Options:",
        Object.keys(push_options).length,
        "rooms",
    );
    Object.entries(push_options).forEach(([roomId, enabled]) => {
        console.log(
            `  - Room ${roomId}: Push notifications ${
                enabled ? "enabled" : "disabled"
            }`,
        );
    });

    // Log Chat List
    console.log("\n💬 Chat List:", chat_list_data.length, "rooms");
    chat_list_data.forEach((room) => {
        console.log(`  - Room: ${room.room_name} (${room.id})`);
        console.log(`    Members: ${room.profiles.length}`);
        room.profiles.forEach((profile: Profile) => {
            console.log(`      • ${profile.nickname} (${profile.id})`);
            // Optional: Log more profile details if needed
            // console.log(`        - Created at: ${profile.created_at}`);
            // console.log(`        - Push notifications: ${profile.push_option}`);
            // console.log(`        - FCM Token: ${profile.fcm_token || "Not set"}`);
        });

        // Log Last Message details
        if (room.last_message != null) {
            console.log(`    Last Message (ID: ${room.last_message.id}):`);
            const message = room.last_message;
            console.log(`      Content: ${message.content || "(No content)"}`);
            console.log(
                `      Type: ${message.type}, User: ${message.user_id}`,
            );
            console.log(`      Sent at: ${message.created_at}`);
            if (message.image_path) {
                console.log(`      Image Path: ${message.image_path}`);
            }
        } else {
            console.log("    Last Message: None");
        }
    });
    console.log("--- End of Fetched Data Summary ---\n");
}

// --- Edge Function ---

Deno.serve(async (req: Request): Promise<Response> => {
    try {
        const { userId } = await req.json();

        if (!userId) {
            return new Response(
                JSON.stringify({ error: "User ID is required" }),
                {
                    status: 400,
                    headers: { "Content-Type": "application/json" },
                },
            );
        }

        // First fetch blocked users to use in chat list sorting
        const blocked_user_ids = await fetchBlockedUsers(userId);

        // Then fetch the remaining data in parallel (excluding chat list)
        console.log(`⏳ Fetching remaining data in parallel`);
        const [blocked_message_ids, push_options] = await Promise.all([
            fetchBlockedMessages(userId),
            fetchPushOptions(userId),
        ]);

        // Fetch chat list separately
        let chat_list_data = await loadChatList(userId);

        // Fetch latest messages for the chat list if chat_list_data is not null
        if (chat_list_data) {
            chat_list_data = await fetchLatestMessagesForRooms(chat_list_data);
        } else {
            chat_list_data = []; // Ensure it's an empty array if null/undefined
        }

        const room_ids = chat_list_data.map((room) => room.id);

        const [latest_read_receipts, initial_messages, initial_image_messages] =
            await Promise.all([
                fetchLatestReadReceipts(userId, room_ids),
                fetchInitialMessages(
                    room_ids,
                    blocked_user_ids, // Ensure these are fetched before this Promise.all
                    blocked_message_ids, // Ensure these are fetched before this Promise.all
                ),
                fetchInitialImageMessages(
                    room_ids,
                    blocked_user_ids,
                    blocked_message_ids,
                ),
            ]);

        console.log(
            `✅ Fetched latest read receipts for ${room_ids.length} rooms.`,
        );
        console.log(
            `✅ Fetched initial messages for ${room_ids.length} rooms.`,
        );
        // Log information about fetched image messages
        try {
            let totalImageMessages = 0;
            let roomsWithImages = 0;

            // Count total image messages and rooms with images
            Object.entries(initial_image_messages).forEach(
                ([roomId, messages]) => {
                    if (messages && messages.length > 0) {
                        totalImageMessages += messages.length;
                        roomsWithImages++;
                        console.log(
                            `🖼️ Room ${roomId}: ${messages.length} image messages`,
                        );
                    }
                },
            );

            // Log summary statistics for better debugging
            console.log(
                `✅ Fetched ${totalImageMessages} total image messages across ${roomsWithImages}/${room_ids.length} rooms`,
            );
        } catch (error) {
            console.error(`❌ Error logging image messages data: ${error}`);
            // Continue execution despite logging error
        }

        // --- ✨ 안 읽은 메시지 ID 목록 계산 호출 ---
        const unreadMessageIdsByRoom = await calculateUnreadCounts(
            userId,
            latest_read_receipts,
            room_ids,
        );

        // --- ✨ ---

        // // Log the fetched data using the helper function (optional)
        // logFetchedData(
        //     blocked_user_ids,
        //     blocked_message_ids,
        //     push_options,
        //     chat_list_data,
        // );

        return new Response(
            JSON.stringify({
                blocked_user_ids,
                blocked_message_ids,
                push_options,
                chat_list: chat_list_data,
                latest_read_receipts: latest_read_receipts,
                initial_messages: initial_messages,
                // --- ✨ 계산된 안 읽은 메시지 ID 목록 추가 ---
                unread_message_ids_by_room: unreadMessageIdsByRoom,
                // --- ✨ ---
                image_messages_by_room: initial_image_messages,
            }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            },
        );
    } catch (error: any) {
        console.error("Error in get-initial-chat-data:", error);
        return new Response(
            JSON.stringify({ error: error.message || "Unknown error" }),
            {
                status: 500,
                headers: { "Content-Type": "application/json" },
            },
        );
    }
});
