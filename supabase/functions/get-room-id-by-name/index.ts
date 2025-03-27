// get-room-id-by-name.ts
import { createClient } from "npm:@supabase/supabase-js@2";

const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const supabase = createClient(supabaseUrl, serviceKey);

Deno.serve(async (req: Request): Promise<Response> => {
    try {
        const { room_name } = await req.json();

        if (!room_name) {
            return new Response(
                JSON.stringify({ error: "room_name is required" }),
                {
                    status: 400,
                },
            );
        }

        const { data, error } = await supabase
            .from("rooms")
            .select("id")
            .eq("room_name", room_name.trim()) // ← eq로 변경
            .maybeSingle();

        if (error) {
            console.error("❌ Supabase Error:", error.message);
            return new Response(JSON.stringify({ error: "Database error" }), {
                status: 500,
            });
        }

        if (!data) {
            return new Response(JSON.stringify({ error: "Room not found" }), {
                status: 404,
            });
        }

        return new Response(JSON.stringify({ room_id: data.id }), {
            headers: { "Content-Type": "application/json" },
        });
    } catch (e) {
        console.error("❌ Invalid request:", e);
        return new Response(JSON.stringify({ error: "Invalid JSON" }), {
            status: 400,
        });
    }
});
