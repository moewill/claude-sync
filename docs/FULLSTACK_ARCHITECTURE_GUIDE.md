# Full-Stack Architecture Guide
*The complete methodology for building production-ready Next.js + Supabase applications*

## Table of Contents
1. [Core Principles](#core-principles)
2. [TypeScript Patterns](#typescript-patterns)
3. [Project Structure](#project-structure)
4. [Component Architecture](#component-architecture)
5. [Database & Supabase Integration](#database--supabase-integration)
6. [API Design Patterns](#api-design-patterns)
7. [Authentication Implementation](#authentication-implementation)
8. [Design System](#design-system)
9. [Performance & Security](#performance--security)
10. [Development Workflow](#development-workflow)

## Core Principles

### 1. Type Safety First
- **Never use `any`** - Always define explicit types
- **Database-first typing** - Generate types from Supabase schema
- **Props interfaces** - Every component has explicit prop types
- **API response typing** - Consistent response shapes

### 2. Server-First Architecture
- **Server Components by default** - Use Next.js App Router SSR
- **Client Components sparingly** - Only when interactivity required
- **Data fetching in RSCs** - Avoid useEffect for data fetching
- **Progressive enhancement** - Works without JavaScript

### 3. Security by Default
- **Row Level Security (RLS)** - Always enabled on Supabase
- **Environment variables** - Never expose secrets to client
- **Input validation** - Server-side validation always
- **CSRF protection** - Built into Next.js

### 4. Performance Optimization
- **Minimal client JavaScript** - Ship less code
- **Image optimization** - Use Next.js Image component
- **Database indexing** - Proper indexes for queries
- **Caching strategies** - Leverage Next.js caching

## TypeScript Patterns

### Component Props
\`\`\`typescript
// ✅ Always use explicit interfaces
interface UserCardProps {
  user: {
    id: string
    email: string
    name: string | null
    avatar_url?: string
  }
  onEdit?: (userId: string) => void
  className?: string
  variant?: 'default' | 'compact' | 'detailed'
}

// ✅ Use the interface in component
export function UserCard({ user, onEdit, className, variant = 'default' }: UserCardProps) {
  // Component implementation
}
\`\`\`

### Database Entity Types
\`\`\`typescript
// ✅ Match Supabase schema exactly
interface User {
  id: string
  email: string
  name: string | null
  avatar_url: string | null
  created_at: string
  updated_at: string
}

interface Post {
  id: string
  title: string
  content: string
  author_id: string
  published: boolean
  created_at: string
  updated_at: string
  // Relations
  author?: User
  comments?: Comment[]
}
\`\`\`

### API Response Types
\`\`\`typescript
// ✅ Consistent API response shape
interface ApiResponse<T> {
  data: T | null
  error: string | null
  status: number
}

// ✅ Usage in API routes
export async function GET(): Promise<Response> {
  try {
    const { data, error } = await supabase.from('users').select('*')
    
    if (error) {
      return Response.json({ data: null, error: error.message, status: 400 })
    }
    
    return Response.json({ data, error: null, status: 200 })
  } catch (err) {
    return Response.json({ data: null, error: 'Internal server error', status: 500 })
  }
}
\`\`\`

### Form Validation Types
\`\`\`typescript
// ✅ Zod schemas for validation
import { z } from 'zod'

const CreateUserSchema = z.object({
  email: z.string().email('Invalid email format'),
  name: z.string().min(2, 'Name must be at least 2 characters'),
  password: z.string().min(8, 'Password must be at least 8 characters')
})

type CreateUserInput = z.infer<typeof CreateUserSchema>
\`\`\`

## Project Structure

### File Organization
\`\`\`
app/
├── (auth)/                 # Route groups for auth pages
│   ├── login/
│   │   └── page.tsx
│   ├── signup/
│   │   └── page.tsx
│   └── layout.tsx         # Auth-specific layout
├── (dashboard)/           # Protected dashboard routes
│   ├── dashboard/
│   │   └── page.tsx
│   ├── settings/
│   │   └── page.tsx
│   └── layout.tsx         # Dashboard layout with nav
├── api/                   # API routes
│   ├── auth/
│   │   └── callback/
│   │       └── route.ts
│   ├── users/
│   │   └── route.ts
│   └── posts/
│       ├── route.ts
│       └── [id]/
│           └── route.ts
├── globals.css            # Tailwind + design tokens
├── layout.tsx             # Root layout
├── page.tsx               # Homepage
└── not-found.tsx          # 404 page

components/
├── ui/                    # shadcn/ui components
│   ├── button.tsx
│   ├── card.tsx
│   ├── input.tsx
│   └── form.tsx
├── forms/                 # Form components
│   ├── login-form.tsx
│   ├── signup-form.tsx
│   └── user-profile-form.tsx
├── layout/                # Layout components
│   ├── header.tsx
│   ├── sidebar.tsx
│   └── footer.tsx
└── features/              # Feature-specific components
    ├── auth/
    ├── dashboard/
    └── posts/

lib/
├── supabase/
│   ├── client.ts          # Browser client
│   ├── server.ts          # Server client
│   └── middleware.ts      # Auth middleware
├── validations/           # Zod schemas
│   ├── auth.ts
│   └── user.ts
├── types.ts               # Shared TypeScript types
├── utils.ts               # Utility functions
└── constants.ts           # App constants

scripts/                   # Database scripts
├── 001_initial_schema.sql
├── 002_add_posts_table.sql
└── 003_setup_rls.sql

middleware.ts              # Next.js middleware
\`\`\`

### Naming Conventions
- **Files**: kebab-case (`user-profile.tsx`, `login-form.tsx`)
- **Components**: PascalCase (`UserProfile`, `LoginForm`)
- **Functions**: camelCase (`getUserById`, `createPost`)
- **Constants**: SCREAMING_SNAKE_CASE (`API_BASE_URL`, `MAX_FILE_SIZE`)
- **Database tables**: snake_case (`users`, `user_posts`)

## Component Architecture

### Server Components (Default)
\`\`\`typescript
// ✅ Server Component - data fetching at component level
import { createServerClient } from '@/lib/supabase/server'

interface DashboardPageProps {
  searchParams: { page?: string }
}

export default async function DashboardPage({ searchParams }: DashboardPageProps) {
  const supabase = createServerClient()
  const page = Number(searchParams.page) || 1
  
  const { data: posts, error } = await supabase
    .from('posts')
    .select('*, author:users(name, avatar_url)')
    .range((page - 1) * 10, page * 10 - 1)
    .order('created_at', { ascending: false })
  
  if (error) {
    throw new Error('Failed to fetch posts')
  }
  
  return (
    <main className="container mx-auto py-8">
      <h1 className="text-3xl font-bold mb-8">Dashboard</h1>
      <PostList posts={posts} />
      <Pagination currentPage={page} />
    </main>
  )
}
\`\`\`

### Client Components (When Needed)
\`\`\`typescript
// ✅ Client Component - only when interactivity required
'use client'

import { useState } from 'react'
import { createBrowserClient } from '@/lib/supabase/client'

interface LikeButtonProps {
  postId: string
  initialLikes: number
  userHasLiked: boolean
}

export function LikeButton({ postId, initialLikes, userHasLiked }: LikeButtonProps) {
  const [likes, setLikes] = useState(initialLikes)
  const [hasLiked, setHasLiked] = useState(userHasLiked)
  const [isLoading, setIsLoading] = useState(false)
  
  const supabase = createBrowserClient()
  
  const handleLike = async () => {
    setIsLoading(true)
    
    try {
      if (hasLiked) {
        await supabase.from('post_likes').delete().eq('post_id', postId)
        setLikes(prev => prev - 1)
        setHasLiked(false)
      } else {
        await supabase.from('post_likes').insert({ post_id: postId })
        setLikes(prev => prev + 1)
        setHasLiked(true)
      }
    } catch (error) {
      console.error('Failed to update like:', error)
    } finally {
      setIsLoading(false)
    }
  }
  
  return (
    <button
      onClick={handleLike}
      disabled={isLoading}
      className="flex items-center gap-2 px-3 py-1 rounded-md hover:bg-gray-100"
    >
      <Heart className={hasLiked ? 'fill-red-500 text-red-500' : 'text-gray-500'} />
      <span>{likes}</span>
    </button>
  )
}
\`\`\`

### Component Composition Patterns
\`\`\`typescript
// ✅ Compound component pattern
interface CardProps {
  children: React.ReactNode
  className?: string
}

interface CardHeaderProps {
  children: React.ReactNode
  className?: string
}

interface CardContentProps {
  children: React.ReactNode
  className?: string
}

export function Card({ children, className }: CardProps) {
  return (
    <div className={cn('rounded-lg border bg-card text-card-foreground shadow-sm', className)}>
      {children}
    </div>
  )
}

export function CardHeader({ children, className }: CardHeaderProps) {
  return (
    <div className={cn('flex flex-col space-y-1.5 p-6', className)}>
      {children}
    </div>
  )
}

export function CardContent({ children, className }: CardContentProps) {
  return (
    <div className={cn('p-6 pt-0', className)}>
      {children}
    </div>
  )
}

// ✅ Usage
<Card>
  <CardHeader>
    <h2 className="text-xl font-semibold">User Profile</h2>
  </CardHeader>
  <CardContent>
    <UserDetails user={user} />
  </CardContent>
</Card>
\`\`\`

## Database & Supabase Integration

### Client Setup
\`\`\`typescript
// lib/supabase/server.ts
import { createServerClient as createSupabaseServerClient } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createServerClient() {
  const cookieStore = cookies()
  
  return createSupabaseServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return cookieStore.getAll()
        },
        setAll(cookiesToSet) {
          try {
            cookiesToSet.forEach(({ name, value, options }) =>
              cookieStore.set(name, value, options)
            )
          } catch {
            // The `setAll` method was called from a Server Component.
            // This can be ignored if you have middleware refreshing
            // user sessions.
          }
        },
      },
    }
  )
}
\`\`\`

\`\`\`typescript
// lib/supabase/client.ts
import { createBrowserClient as createSupabaseBrowserClient } from '@supabase/ssr'

let client: ReturnType<typeof createSupabaseBrowserClient> | null = null

export function createBrowserClient() {
  if (!client) {
    client = createSupabaseBrowserClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
    )
  }
  return client
}
\`\`\`

### Database Schema Patterns
\`\`\`sql
-- scripts/001_initial_schema.sql
-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Posts table
CREATE TABLE public.posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  author_id UUID REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
  published BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_posts_author_id ON public.posts(author_id);
CREATE INDEX idx_posts_created_at ON public.posts(created_at DESC);
CREATE INDEX idx_posts_published ON public.posts(published) WHERE published = TRUE;

-- Updated at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_posts_updated_at BEFORE UPDATE ON public.posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
\`\`\`

### Row Level Security (RLS)
\`\`\`sql
-- scripts/002_setup_rls.sql
-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "Users can read own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- Anyone can read published posts
CREATE POLICY "Anyone can read published posts" ON public.posts
  FOR SELECT USING (published = TRUE);

-- Authors can read their own posts
CREATE POLICY "Authors can read own posts" ON public.posts
  FOR SELECT USING (auth.uid() = author_id);

-- Authors can create posts
CREATE POLICY "Authors can create posts" ON public.posts
  FOR INSERT WITH CHECK (auth.uid() = author_id);

-- Authors can update their own posts
CREATE POLICY "Authors can update own posts" ON public.posts
  FOR UPDATE USING (auth.uid() = author_id);

-- Authors can delete their own posts
CREATE POLICY "Authors can delete own posts" ON public.posts
  FOR DELETE USING (auth.uid() = author_id);
\`\`\`

### Query Patterns
\`\`\`typescript
// ✅ Type-safe queries with proper error handling
export async function getUserPosts(userId: string) {
  const supabase = createServerClient()
  
  const { data, error } = await supabase
    .from('posts')
    .select(`
      id,
      title,
      content,
      published,
      created_at,
      author:users(name, avatar_url)
    `)
    .eq('author_id', userId)
    .order('created_at', { ascending: false })
  
  if (error) {
    throw new Error(`Failed to fetch user posts: ${error.message}`)
  }
  
  return data
}

// ✅ Pagination helper
export async function getPaginatedPosts(page: number = 1, limit: number = 10) {
  const supabase = createServerClient()
  const offset = (page - 1) * limit
  
  const [postsResult, countResult] = await Promise.all([
    supabase
      .from('posts')
      .select(`
        id,
        title,
        content,
        created_at,
        author:users(name, avatar_url)
      `)
      .eq('published', true)
      .order('created_at', { ascending: false })
      .range(offset, offset + limit - 1),
    
    supabase
      .from('posts')
      .select('*', { count: 'exact', head: true })
      .eq('published', true)
  ])
  
  if (postsResult.error) {
    throw new Error(`Failed to fetch posts: ${postsResult.error.message}`)
  }
  
  return {
    posts: postsResult.data,
    totalCount: countResult.count || 0,
    totalPages: Math.ceil((countResult.count || 0) / limit),
    currentPage: page
  }
}
\`\`\`

## API Design Patterns

### Route Handlers
\`\`\`typescript
// app/api/posts/route.ts
import { createServerClient } from '@/lib/supabase/server'
import { NextRequest } from 'next/server'
import { z } from 'zod'

const CreatePostSchema = z.object({
  title: z.string().min(1, 'Title is required'),
  content: z.string().min(1, 'Content is required'),
  published: z.boolean().default(false)
})

export async function GET(request: NextRequest) {
  try {
    const supabase = createServerClient()
    const { searchParams } = new URL(request.url)
    const page = Number(searchParams.get('page')) || 1
    const limit = Number(searchParams.get('limit')) || 10
    
    const { data, error } = await supabase
      .from('posts')
      .select('*, author:users(name, avatar_url)')
      .eq('published', true)
      .order('created_at', { ascending: false })
      .range((page - 1) * limit, page * limit - 1)
    
    if (error) {
      return Response.json({ data: null, error: error.message }, { status: 400 })
    }
    
    return Response.json({ data, error: null })
  } catch (error) {
    return Response.json(
      { data: null, error: 'Internal server error' },
      { status: 500 }
    )
  }
}

export async function POST(request: NextRequest) {
  try {
    const supabase = createServerClient()
    
    // Check authentication
    const { data: { user }, error: authError } = await supabase.auth.getUser()
    if (authError || !user) {
      return Response.json(
        { data: null, error: 'Unauthorized' },
        { status: 401 }
      )
    }
    
    // Validate request body
    const body = await request.json()
    const validatedData = CreatePostSchema.parse(body)
    
    // Create post
    const { data, error } = await supabase
      .from('posts')
      .insert({
        ...validatedData,
        author_id: user.id
      })
      .select('*, author:users(name, avatar_url)')
      .single()
    
    if (error) {
      return Response.json({ data: null, error: error.message }, { status: 400 })
    }
    
    return Response.json({ data, error: null }, { status: 201 })
  } catch (error) {
    if (error instanceof z.ZodError) {
      return Response.json(
        { data: null, error: error.errors[0].message },
        { status: 400 }
      )
    }
    
    return Response.json(
      { data: null, error: 'Internal server error' },
      { status: 500 }
    )
  }
}
\`\`\`

### Server Actions
\`\`\`typescript
// lib/actions/posts.ts
'use server'

import { createServerClient } from '@/lib/supabase/server'
import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { z } from 'zod'

const CreatePostSchema = z.object({
  title: z.string().min(1, 'Title is required'),
  content: z.string().min(1, 'Content is required'),
  published: z.boolean().default(false)
})

export async function createPost(formData: FormData) {
  const supabase = createServerClient()
  
  // Check authentication
  const { data: { user }, error: authError } = await supabase.auth.getUser()
  if (authError || !user) {
    throw new Error('Unauthorized')
  }
  
  // Validate form data
  const validatedData = CreatePostSchema.parse({
    title: formData.get('title'),
    content: formData.get('content'),
    published: formData.get('published') === 'on'
  })
  
  // Create post
  const { data, error } = await supabase
    .from('posts')
    .insert({
      ...validatedData,
      author_id: user.id
    })
    .select()
    .single()
  
  if (error) {
    throw new Error(`Failed to create post: ${error.message}`)
  }
  
  revalidatePath('/dashboard')
  redirect(`/posts/${data.id}`)
}

export async function deletePost(postId: string) {
  const supabase = createServerClient()
  
  const { error } = await supabase
    .from('posts')
    .delete()
    .eq('id', postId)
  
  if (error) {
    throw new Error(`Failed to delete post: ${error.message}`)
  }
  
  revalidatePath('/dashboard')
}
\`\`\`

## Authentication Implementation

### Middleware Setup
\`\`\`typescript
// middleware.ts
import { createServerClient } from '@supabase/ssr'
import { NextResponse, type NextRequest } from 'next/server'

export async function middleware(request: NextRequest) {
  let supabaseResponse = NextResponse.next({
    request,
  })

  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        getAll() {
          return request.cookies.getAll()
        },
        setAll(cookiesToSet) {
          cookiesToSet.forEach(({ name, value, options }) => request.cookies.set(name, value))
          supabaseResponse = NextResponse.next({
            request,
          })
          cookiesToSet.forEach(({ name, value, options }) =>
            supabaseResponse.cookies.set(name, value, options)
          )
        },
      },
    }
  )

  // Refresh session if expired
  const { data: { user } } = await supabase.auth.getUser()

  // Protect dashboard routes
  if (request.nextUrl.pathname.startsWith('/dashboard') && !user) {
    return NextResponse.redirect(new URL('/login', request.url))
  }

  // Redirect authenticated users away from auth pages
  if ((request.nextUrl.pathname === '/login' || request.nextUrl.pathname === '/signup') && user) {
    return NextResponse.redirect(new URL('/dashboard', request.url))
  }

  return supabaseResponse
}

export const config = {
  matcher: [
    '/((?!_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
}
\`\`\`

### Auth Components
\`\`\`typescript
// components/forms/login-form.tsx
'use client'

import { useState } from 'react'
import { createBrowserClient } from '@/lib/supabase/client'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'

export function LoginForm() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  
  const supabase = createBrowserClient()
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsLoading(true)
    setError(null)
    
    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password
      })
      
      if (error) {
        setError(error.message)
      }
    } catch (err) {
      setError('An unexpected error occurred')
    } finally {
      setIsLoading(false)
    }
  }
  
  return (
    <form onSubmit={handleSubmit} className="space-y-4">
      <div className="space-y-2">
        <Label htmlFor="email">Email</Label>
        <Input
          id="email"
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
        />
      </div>
      
      <div className="space-y-2">
        <Label htmlFor="password">Password</Label>
        <Input
          id="password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
      </div>
      
      {error && (
        <div className="text-sm text-red-600">
          {error}
        </div>
      )}
      
      <Button type="submit" disabled={isLoading} className="w-full">
        {isLoading ? 'Signing in...' : 'Sign in'}
      </Button>
    </form>
  )
}
\`\`\`

### Auth Callback Handler
\`\`\`typescript
// app/api/auth/callback/route.ts
import { createServerClient } from '@/lib/supabase/server'
import { NextRequest, NextResponse } from 'next/server'

export async function GET(request: NextRequest) {
  const { searchParams, origin } = new URL(request.url)
  const code = searchParams.get('code')
  const next = searchParams.get('next') ?? '/dashboard'

  if (code) {
    const supabase = createServerClient()
    const { error } = await supabase.auth.exchangeCodeForSession(code)
    
    if (!error) {
      return NextResponse.redirect(`${origin}${next}`)
    }
  }

  // Return the user to an error page with instructions
  return NextResponse.redirect(`${origin}/auth/auth-code-error`)
}
\`\`\`

## Design System

### Tailwind Configuration
\`\`\`css
/* app/globals.css */
@import 'tailwindcss';

@theme inline {
  /* Colors */
  --color-background: #ffffff;
  --color-foreground: #0f172a;
  --color-card: #ffffff;
  --color-card-foreground: #0f172a;
  --color-popover: #ffffff;
  --color-popover-foreground: #0f172a;
  --color-primary: #0f172a;
  --color-primary-foreground: #f8fafc;
  --color-secondary: #f1f5f9;
  --color-secondary-foreground: #0f172a;
  --color-muted: #f1f5f9;
  --color-muted-foreground: #64748b;
  --color-accent: #f1f5f9;
  --color-accent-foreground: #0f172a;
  --color-destructive: #ef4444;
  --color-destructive-foreground: #f8fafc;
  --color-border: #e2e8f0;
  --color-input: #e2e8f0;
  --color-ring: #0f172a;
  
  /* Dark mode */
  --color-background-dark: #020617;
  --color-foreground-dark: #f8fafc;
  --color-card-dark: #020617;
  --color-card-foreground-dark: #f8fafc;
  --color-popover-dark: #020617;
  --color-popover-foreground-dark: #f8fafc;
  --color-primary-dark: #f8fafc;
  --color-primary-foreground-dark: #0f172a;
  --color-secondary-dark: #1e293b;
  --color-secondary-foreground-dark: #f8fafc;
  --color-muted-dark: #1e293b;
  --color-muted-foreground-dark: #94a3b8;
  --color-accent-dark: #1e293b;
  --color-accent-foreground-dark: #f8fafc;
  --color-destructive-dark: #7f1d1d;
  --color-destructive-foreground-dark: #f8fafc;
  --color-border-dark: #1e293b;
  --color-input-dark: #1e293b;
  --color-ring-dark: #f8fafc;
  
  /* Typography */
  --font-sans: ui-sans-serif, system-ui, sans-serif;
  --font-serif: ui-serif, Georgia, serif;
  --font-mono: ui-monospace, SFMono-Regular, monospace;
  
  /* Spacing & Sizing */
  --radius: 0.5rem;
}

/* Dark mode support */
@media (prefers-color-scheme: dark) {
  :root {
    --color-background: var(--color-background-dark);
    --color-foreground: var(--color-foreground-dark);
    --color-card: var(--color-card-dark);
    --color-card-foreground: var(--color-card-foreground-dark);
    --color-popover: var(--color-popover-dark);
    --color-popover-foreground: var(--color-popover-foreground-dark);
    --color-primary: var(--color-primary-dark);
    --color-primary-foreground: var(--color-primary-foreground-dark);
    --color-secondary: var(--color-secondary-dark);
    --color-secondary-foreground: var(--color-secondary-foreground-dark);
    --color-muted: var(--color-muted-dark);
    --color-muted-foreground: var(--color-muted-foreground-dark);
    --color-accent: var(--color-accent-dark);
    --color-accent-foreground: var(--color-accent-foreground-dark);
    --color-destructive: var(--color-destructive-dark);
    --color-destructive-foreground: var(--color-destructive-foreground-dark);
    --color-border: var(--color-border-dark);
    --color-input: var(--color-input-dark);
    --color-ring: var(--color-ring-dark);
  }
}

/* Base styles */
* {
  border-color: theme(colors.border);
}

body {
  background-color: theme(colors.background);
  color: theme(colors.foreground);
}
\`\`\`

### Component Design Patterns
\`\`\`typescript
// ✅ Consistent component API
interface ButtonProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'default' | 'destructive' | 'outline' | 'secondary' | 'ghost' | 'link'
  size?: 'default' | 'sm' | 'lg' | 'icon'
  asChild?: boolean
}

export const Button = React.forwardRef<HTMLButtonElement, ButtonProps>(
  ({ className, variant = 'default', size = 'default', asChild = false, ...props }, ref) => {
    const Comp = asChild ? Slot : 'button'
    
    return (
      <Comp
        className={cn(buttonVariants({ variant, size, className }))}
        ref={ref}
        {...props}
      />
    )
  }
)
\`\`\`

### Layout Patterns
\`\`\`typescript
// ✅ Consistent layout structure
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <div className="min-h-screen bg-background">
      <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
        <div className="container flex h-14 items-center">
          <MainNav />
          <div className="ml-auto flex items-center space-x-4">
            <UserNav />
          </div>
        </div>
      </header>
      
      <div className="flex-1 space-y-4 p-8 pt-6">
        <div className="flex items-center justify-between space-y-2">
          <h2 className="text-3xl font-bold tracking-tight">Dashboard</h2>
        </div>
        
        <div className="space-y-4">
          {children}
        </div>
      </div>
    </div>
  )
}
\`\`\`

## Performance & Security

### Image Optimization
\`\`\`typescript
// ✅ Always use Next.js Image component
import Image from 'next/image'

interface UserAvatarProps {
  user: {
    name: string | null
    avatar_url: string | null
  }
  size?: number
}

export function UserAvatar({ user, size = 40 }: UserAvatarProps) {
  return (
    <div className="relative overflow-hidden rounded-full">
      {user.avatar_url ? (
        <Image
          src={user.avatar_url || "/placeholder.svg"}
          alt={user.name || 'User avatar'}
          width={size}
          height={size}
          className="object-cover"
        />
      ) : (
        <div 
          className="flex items-center justify-center bg-muted text-muted-foreground"
          style={{ width: size, height: size }}
        >
          {user.name?.charAt(0).toUpperCase() || 'U'}
        </div>
      )}
    </div>
  )
}
\`\`\`

### Error Boundaries
\`\`\`typescript
// components/error-boundary.tsx
'use client'

import { useEffect } from 'react'
import { Button } from '@/components/ui/button'

export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string }
  reset: () => void
}) {
  useEffect(() => {
    console.error(error)
  }, [error])

  return (
    <div className="flex h-[50vh] flex-col items-center justify-center space-y-4">
      <h2 className="text-xl font-semibold">Something went wrong!</h2>
      <p className="text-muted-foreground">
        We apologize for the inconvenience. Please try again.
      </p>
      <Button onClick={reset}>Try again</Button>
    </div>
  )
}
\`\`\`

### Loading States
\`\`\`typescript
// app/dashboard/loading.tsx
export default function Loading() {
  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <div className="h-8 w-48 animate-pulse rounded bg-muted" />
        <div className="h-10 w-32 animate-pulse rounded bg-muted" />
      </div>
      
      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        {Array.from({ length: 6 }).map((_, i) => (
          <div key={i} className="space-y-3 rounded-lg border p-6">
            <div className="h-4 w-3/4 animate-pulse rounded bg-muted" />
            <div className="h-4 w-1/2 animate-pulse rounded bg-muted" />
            <div className="h-20 animate-pulse rounded bg-muted" />
          </div>
        ))}
      </div>
    </div>
  )
}
\`\`\`

## Development Workflow

### Environment Setup
\`\`\`bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=your_supabase_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
NEXT_PUBLIC_DEV_SUPABASE_REDIRECT_URL=http://localhost:3000
\`\`\`

### Database Migrations
\`\`\`typescript
// scripts/run-migration.ts
import { createClient } from '@supabase/supabase-js'
import fs from 'fs'
import path from 'path'

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!
)

async function runMigration(filename: string) {
  const sqlPath = path.join(process.cwd(), 'scripts', filename)
  const sql = fs.readFileSync(sqlPath, 'utf8')
  
  const { error } = await supabase.rpc('exec_sql', { sql })
  
  if (error) {
    console.error(`Migration ${filename} failed:`, error)
    process.exit(1)
  }
  
  console.log(`Migration ${filename} completed successfully`)
}

// Usage: npm run migrate 001_initial_schema.sql
const filename = process.argv[2]
if (filename) {
  runMigration(filename)
} else {
  console.error('Please provide a migration filename')
  process.exit(1)
}
\`\`\`

### Testing Patterns
\`\`\`typescript
// __tests__/components/user-card.test.tsx
import { render, screen } from '@testing-library/react'
import { UserCard } from '@/components/user-card'

const mockUser = {
  id: '1',
  email: 'test@example.com',
  name: 'Test User',
  avatar_url: null,
  created_at: '2024-01-01T00:00:00Z',
  updated_at: '2024-01-01T00:00:00Z'
}

describe('UserCard', () => {
  it('renders user information correctly', () => {
    render(<UserCard user={mockUser} />)
    
    expect(screen.getByText('Test User')).toBeInTheDocument()
    expect(screen.getByText('test@example.com')).toBeInTheDocument()
  })
  
  it('shows fallback when name is null', () => {
    const userWithoutName = { ...mockUser, name: null }
    render(<UserCard user={userWithoutName} />)
    
    expect(screen.getByText('test@example.com')).toBeInTheDocument()
  })
})
\`\`\`

## Key Takeaways

### Always Do
- ✅ Use TypeScript strictly (no `any`)
- ✅ Server Components by default
- ✅ Enable RLS on all tables
- ✅ Validate inputs server-side
- ✅ Use semantic HTML and ARIA
- ✅ Implement proper error boundaries
- ✅ Use Next.js Image for all images
- ✅ Follow consistent naming conventions
- ✅ Write comprehensive prop interfaces

### Never Do
- ❌ Fetch data in useEffect
- ❌ Expose secrets to client
- ❌ Skip input validation
- ❌ Use `any` type
- ❌ Ignore accessibility
- ❌ Skip error handling
- ❌ Use inline styles
- ❌ Hardcode API URLs
- ❌ Skip database indexes

### Architecture Checklist
- [ ] TypeScript interfaces for all props
- [ ] RLS policies on all tables
- [ ] Server Components for data fetching
- [ ] Client Components only when needed
- [ ] Proper error boundaries
- [ ] Loading states for async operations
- [ ] Input validation with Zod
- [ ] Consistent API response shapes
- [ ] Semantic HTML structure
- [ ] Mobile-first responsive design
- [ ] Proper image optimization
- [ ] Environment variable security

This guide represents the complete methodology for building production-ready full-stack applications. Follow these patterns consistently for maintainable, secure, and performant applications.
