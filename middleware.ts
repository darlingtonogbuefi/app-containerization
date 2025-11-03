// middleware.ts

import { updateSession } from './supabase/middleware';
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  // 🧠 Log all incoming requests (structured JSON for Kibana)
  console.log(
    JSON.stringify({
      timestamp: new Date().toISOString(),
      method: request.method,
      path: request.nextUrl.pathname,
      ip: request.ip ?? 'unknown',
    })
  );

  // ✅ Check Supabase session and handle redirects if needed
  const { response } = await updateSession(request);
  return response;
}

// ⚡ Temporary: run middleware on all routes for debugging
export const config = {
  matcher: ['/:path*'],
};
