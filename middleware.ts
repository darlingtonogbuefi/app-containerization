// middleware.ts

// middleware.ts
import { updateSession } from './supabase/middleware';
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  // 🧠 Log incoming requests (structured JSON format for Kibana)
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

// ✅ Limit middleware to protected dashboard routes
export const config = {
  matcher: ['/dashboard/:path*'],
};
