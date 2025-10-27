// middleware.ts

import { updateSession } from './supabase/middleware';
import type { NextRequest } from 'next/server';

export async function middleware(request: NextRequest) {
  const { response } = await updateSession(request);
  return response;
}

export const config = {
  matcher: ['/dashboard/:path*'],
};
