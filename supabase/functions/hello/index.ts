Deno.serve(() => {
    return new Response("Hello, Supabase Edge Functions!", {
        headers: { "Content-Type": "text/plain" },
    });
});
