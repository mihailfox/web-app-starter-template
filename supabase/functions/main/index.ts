// Main Edge Function entrypoint
// This is the default function that handles all edge function requests

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

Deno.serve(async (req: Request) => {
  const url = new URL(req.url);
  
  return new Response(
    JSON.stringify({
      message: "Supabase Edge Functions",
      path: url.pathname,
      timestamp: new Date().toISOString(),
    }),
    {
      headers: {
        "Content-Type": "application/json",
        "Connection": "keep-alive",
      },
    },
  );
});
