import { createClient } from "npm:@supabase/supabase-js@2";

const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

Deno.serve(async (req: Request): Promise<Response> => {
    try {
        // Get user_id from request body
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

        // Delete user from auth
        const { error } = await supabase.auth.admin.deleteUser(userId);

        if (error) {
            console.error(`Error deleting user: ${error.message}`);
            return new Response(
                JSON.stringify({ error: error.message }),
                {
                    status: 500,
                    headers: { "Content-Type": "application/json" },
                },
            );
        }

        return new Response(
            JSON.stringify({ message: "User deleted successfully" }),
            {
                status: 200,
                headers: { "Content-Type": "application/json" },
            },
        );
    } catch (error: any) {
        console.error("Error in delete-auth-user:", error);
        return new Response(
            JSON.stringify({ error: error.message || "Unknown error" }),
            {
                status: 500,
                headers: { "Content-Type": "application/json" },
            },
        );
    }
});
