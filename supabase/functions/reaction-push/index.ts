import { createClient } from "npm:@supabase/supabase-js@2";
import { JWT } from "npm:google-auth-library@9";

interface Notification {
  id: string;
  feed_id: string; // Using feed_id to fetch the feed details
  user_id: string; // This is the user_id of the reaction giver
  body: string;
}

interface WebhookPayload {
  type: "INSERT";
  table: "reactions"; // 테이블 이름을 reactions으로 설정
  record: Notification;
  schema: "public";
}

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json();

  // Step 1: Get the user_id from the feeds table using the feed_id
  const { data: feedData, error: feedError } = await supabase
    .from("feed") // Replace "feed" with the actual table name containing feed_id and user_id
    .select("user_id")
    .eq("id", payload.record.feed_id)
    .single();

  if (feedError || !feedData) {
    console.error("Error fetching user_id from feed_id:", feedError);
    return new Response(JSON.stringify({ error: "Feed not found" }), {
      status: 404,
      headers: { "Content-Type": "application/json" },
    });
  }

  const feedUserId = feedData.user_id;

  // Step 2: Fetch the fcm_token for the feed user_id from the profiles table where push_option is true
  const { data: feedProfileData, error: feedProfileError } = await supabase
    .from("profiles")
    .select("fcm_token, push_option") // Fetch both fcm_token and push_option for better context
    .eq("id", feedUserId)
    .single();

  if (feedProfileError) {
    console.error("Error fetching profile data:", feedProfileError);
    return new Response(
      JSON.stringify({ error: "Error fetching profile data" }),
      {
        status: 500, // Internal server error, as this is unexpected
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  if (!feedProfileData) {
    console.warn("Profile not found for user:", feedUserId);
    return new Response(
      JSON.stringify({ error: "Profile not found" }),
      {
        status: 404,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  const { fcm_token: fcmToken, push_option: pushOption } = feedProfileData;

  // Check if notifications are globally disabled (fcm_token is null)
  if (!fcmToken) {
    console.warn(
      "User has disabled all notifications (fcm_token is null).",
      { user_id: feedUserId },
    );
    return new Response(
      JSON.stringify({
        message: "All notifications are disabled for this user.",
      }),
      {
        status: 200, // Normal behavior, not an error
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  // Check if reaction-specific notifications are disabled (push_option is false)
  if (!pushOption) {
    console.info(
      "User has disabled reaction-specific notifications (push_option is false).",
      { user_id: feedUserId },
    );
    return new Response(
      JSON.stringify({
        message: "Reaction-specific notifications are disabled for this user.",
      }),
      {
        status: 200, // Normal behavior, not an error
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  // Proceed with push notification if both conditions are satisfied
  console.log("Push notifications are enabled for this user.");

  // const fcmToken = feedProfileData.fcm_token as string;

  // Step 3: Fetch the nickname for the reaction giver (record.user_id)
  const { data: reactionUserData, error: reactionUserError } = await supabase
    .from("profiles")
    .select("nickname")
    .eq("id", payload.record.user_id) // Use record.user_id to get the reaction giver's nickname
    .single();

  if (reactionUserError || !reactionUserData) {
    console.error(
      "Error fetching nickname for the reaction giver:",
      reactionUserError,
    );
    return new Response(JSON.stringify({ error: "Nickname not found" }), {
      status: 404,
      headers: { "Content-Type": "application/json" },
    });
  }

  const reactionGiverNickname = reactionUserData.nickname as string;

  // Step 4: Send the push notification via FCM with nickname in the body
  const accessToken = await getAccessToken({
    clientEmail: Deno.env.get("client_email")!,
    privateKey: Deno.env.get("private_key")!.replace(/\\n/g, "\n"),
  });

  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/udaadaa/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token: fcmToken,
          notification: {
            title: "식단이 응원을 받았어요 🎉🎉",
            body: `${reactionGiverNickname}님이 응원을 해주셨어요 👏🏼👏🏼`,
          },
          data: {
            feedId: payload.record.feed_id, // 추가
            type: "reaction",
          },
        },
      }),
    },
  );

  const resData = await res.json();
  if (res.status < 200 || 299 < res.status) {
    console.error("Error sending notification:", resData);
    return new Response(JSON.stringify(resData), {
      status: res.status,
      headers: { "Content-Type": "application/json" },
    });
  }

  return new Response(JSON.stringify(resData), {
    headers: { "Content-Type": "application/json" },
  });
});

// Function to get the access token for FCM
const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string;
  privateKey: string;
}): Promise<string> => {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ["https://www.googleapis.com/auth/firebase.messaging"],
    });
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err);
        return;
      }
      resolve(tokens!.access_token!);
    });
  });
};
