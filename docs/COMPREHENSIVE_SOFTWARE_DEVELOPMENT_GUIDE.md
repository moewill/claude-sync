# Comprehensive Software Development Guide
*Instructions and methodologies for creating amazing software*

## Table of Contents
1. [Core Development Principles](#core-development-principles)
2. [Architecture & Design Patterns](#architecture--design-patterns)
3. [Code Quality & Standards](#code-quality--standards)
4. [Testing Methodologies](#testing-methodologies)
5. [Performance Optimization](#performance-optimization)
6. [Security Best Practices](#security-best-practices)
7. [User Experience Principles](#user-experience-principles)
8. [Project Management & Workflow](#project-management--workflow)
9. [Debugging & Troubleshooting](#debugging--troubleshooting)
10. [Continuous Learning & Improvement](#continuous-learning--improvement)
11. [AI-Assisted Development](#ai-assisted-development)
12. [Team Collaboration](#team-collaboration)

---

## Core Development Principles

### The SOLID Principles
**Single Responsibility Principle (SRP)**
- Each class/function should have one reason to change
- Break down complex components into smaller, focused units
- Example: Separate data fetching from UI rendering

**Open/Closed Principle (OCP)**
- Open for extension, closed for modification
- Use composition over inheritance
- Design interfaces that can be extended without changing existing code

**Liskov Substitution Principle (LSP)**
- Derived classes must be substitutable for their base classes
- Ensure consistent behavior across implementations
- Maintain contract expectations

**Interface Segregation Principle (ISP)**
- Clients shouldn't depend on interfaces they don't use
- Create specific, focused interfaces
- Avoid "fat" interfaces with too many methods

**Dependency Inversion Principle (DIP)**
- Depend on abstractions, not concretions
- Use dependency injection
- Invert control flow for better testability

### DRY (Don't Repeat Yourself)
\`\`\`typescript
// Bad: Repetitive validation
function validateEmail(email: string) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)
}

function validateUserEmail(user: User) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(user.email)
}

// Good: Single source of truth
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
const isValidEmail = (email: string) => EMAIL_REGEX.test(email)

function validateEmail(email: string) {
  return isValidEmail(email)
}

function validateUserEmail(user: User) {
  return isValidEmail(user.email)
}
\`\`\`

### KISS (Keep It Simple, Stupid)
- Choose the simplest solution that works
- Avoid premature optimization
- Write code that's easy to understand and maintain
- Prefer explicit over clever

### YAGNI (You Aren't Gonna Need It)
- Don't build features until you need them
- Avoid speculative generality
- Focus on current requirements
- Refactor when new requirements emerge

---

## Architecture & Design Patterns

### Layered Architecture
\`\`\`
┌─────────────────────┐
│   Presentation      │ ← UI Components, Pages
├─────────────────────┤
│   Business Logic    │ ← Services, Use Cases
├─────────────────────┤
│   Data Access       │ ← Repositories, APIs
├─────────────────────┤
│   Database/External │ ← Database, External APIs
└─────────────────────┘
\`\`\`

### Component-Based Architecture
\`\`\`typescript
// Container Component (Smart)
function UserProfileContainer({ userId }: { userId: string }) {
  const { data: user, loading, error } = useUser(userId)
  
  if (loading) return <LoadingSpinner />
  if (error) return <ErrorMessage error={error} />
  if (!user) return <NotFound />
  
  return <UserProfile user={user} onUpdate={handleUpdate} />
}

// Presentational Component (Dumb)
interface UserProfileProps {
  user: User
  onUpdate: (user: User) => void
}

function UserProfile({ user, onUpdate }: UserProfileProps) {
  return (
    <div className="user-profile">
      <Avatar src={user.avatar} />
      <h1>{user.name}</h1>
      <EditButton onClick={() => onUpdate(user)} />
    </div>
  )
}
\`\`\`

### Repository Pattern
\`\`\`typescript
interface UserRepository {
  findById(id: string): Promise<User | null>
  findByEmail(email: string): Promise<User | null>
  create(user: CreateUserData): Promise<User>
  update(id: string, data: UpdateUserData): Promise<User>
  delete(id: string): Promise<void>
}

class SupabaseUserRepository implements UserRepository {
  constructor(private supabase: SupabaseClient) {}
  
  async findById(id: string): Promise<User | null> {
    const { data, error } = await this.supabase
      .from('users')
      .select('*')
      .eq('id', id)
      .single()
    
    if (error) throw new Error(error.message)
    return data
  }
  
  // ... other methods
}
\`\`\`

### Service Layer Pattern
\`\`\`typescript
class UserService {
  constructor(
    private userRepo: UserRepository,
    private emailService: EmailService,
    private logger: Logger
  ) {}
  
  async createUser(userData: CreateUserData): Promise<User> {
    // Validation
    if (!isValidEmail(userData.email)) {
      throw new ValidationError('Invalid email format')
    }
    
    // Business logic
    const existingUser = await this.userRepo.findByEmail(userData.email)
    if (existingUser) {
      throw new ConflictError('User already exists')
    }
    
    // Create user
    const user = await this.userRepo.create(userData)
    
    // Side effects
    await this.emailService.sendWelcomeEmail(user.email)
    this.logger.info('User created', { userId: user.id })
    
    return user
  }
}
\`\`\`

### Event-Driven Architecture
\`\`\`typescript
// Event system
class EventEmitter {
  private listeners: Map<string, Function[]> = new Map()
  
  on(event: string, callback: Function) {
    if (!this.listeners.has(event)) {
      this.listeners.set(event, [])
    }
    this.listeners.get(event)!.push(callback)
  }
  
  emit(event: string, data: any) {
    const callbacks = this.listeners.get(event) || []
    callbacks.forEach(callback => callback(data))
  }
}

// Usage
const events = new EventEmitter()

// Listeners
events.on('user.created', (user: User) => {
  emailService.sendWelcomeEmail(user.email)
})

events.on('user.created', (user: User) => {
  analytics.track('User Registered', { userId: user.id })
})

// Emitter
async function createUser(userData: CreateUserData) {
  const user = await userRepo.create(userData)
  events.emit('user.created', user)
  return user
}
\`\`\`

---

## Code Quality & Standards

### TypeScript Best Practices

**Strict Type Configuration**
\`\`\`json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "noImplicitReturns": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true
  }
}
\`\`\`

**Interface Design**
\`\`\`typescript
// Good: Specific, focused interfaces
interface CreateUserRequest {
  email: string
  name: string
  password: string
}

interface UpdateUserRequest {
  name?: string
  avatar?: string
}

interface UserResponse {
  id: string
  email: string
  name: string
  createdAt: string
  updatedAt: string
}

// Use discriminated unions for complex states
type LoadingState = 
  | { status: 'idle' }
  | { status: 'loading' }
  | { status: 'success'; data: User }
  | { status: 'error'; error: string }
\`\`\`

**Generic Constraints**
\`\`\`typescript
// Constrain generics for better type safety
interface Repository<T extends { id: string }> {
  findById(id: string): Promise<T | null>
  create(data: Omit<T, 'id'>): Promise<T>
  update(id: string, data: Partial<T>): Promise<T>
}

// Utility types for better API design
type ApiResponse<T> = {
  data: T
  meta: {
    total: number
    page: number
    limit: number
  }
}

type PaginatedResponse<T> = ApiResponse<T[]>
\`\`\`

### Error Handling Patterns

**Result Pattern**
\`\`\`typescript
type Result<T, E = Error> = 
  | { success: true; data: T }
  | { success: false; error: E }

async function safeApiCall<T>(
  apiCall: () => Promise<T>
): Promise<Result<T>> {
  try {
    const data = await apiCall()
    return { success: true, data }
  } catch (error) {
    return { 
      success: false, 
      error: error instanceof Error ? error : new Error(String(error))
    }
  }
}

// Usage
const result = await safeApiCall(() => fetchUser(id))
if (result.success) {
  console.log(result.data.name) // Type-safe access
} else {
  console.error(result.error.message)
}
\`\`\`

**Custom Error Classes**
\`\`\`typescript
abstract class AppError extends Error {
  abstract readonly statusCode: number
  abstract readonly isOperational: boolean
  
  constructor(message: string, public readonly context?: Record<string, any>) {
    super(message)
    this.name = this.constructor.name
  }
}

class ValidationError extends AppError {
  readonly statusCode = 400
  readonly isOperational = true
}

class NotFoundError extends AppError {
  readonly statusCode = 404
  readonly isOperational = true
}

class DatabaseError extends AppError {
  readonly statusCode = 500
  readonly isOperational = false
}
\`\`\`

### Code Organization

**Feature-Based Structure**
\`\`\`
src/
├── features/
│   ├── auth/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   ├── types.ts
│   │   └── index.ts
│   ├── users/
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   ├── types.ts
│   │   └── index.ts
├── shared/
│   ├── components/
│   ├── hooks/
│   ├── utils/
│   └── types/
└── app/
\`\`\`

**Barrel Exports**
\`\`\`typescript
// features/auth/index.ts
export { LoginForm } from './components/LoginForm'
export { useAuth } from './hooks/useAuth'
export { authService } from './services/authService'
export type { User, LoginCredentials } from './types'

// Usage
import { LoginForm, useAuth, type User } from '@/features/auth'
\`\`\`

---

## Testing Methodologies

### Testing Pyramid
\`\`\`
    ┌─────────────┐
    │   E2E Tests │ ← Few, expensive, high confidence
    ├─────────────┤
    │ Integration │ ← Some, moderate cost/confidence
    ├─────────────┤
    │ Unit Tests  │ ← Many, cheap, fast feedback
    └─────────────┘
\`\`\`

### Unit Testing Best Practices

**AAA Pattern (Arrange, Act, Assert)**
\`\`\`typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = {
        email: 'test@example.com',
        name: 'Test User',
        password: 'password123'
      }
      const mockUser = { id: '1', ...userData }
      const mockUserRepo = {
        findByEmail: jest.fn().mockResolvedValue(null),
        create: jest.fn().mockResolvedValue(mockUser)
      }
      const userService = new UserService(mockUserRepo, mockEmailService, mockLogger)
      
      // Act
      const result = await userService.createUser(userData)
      
      // Assert
      expect(result).toEqual(mockUser)
      expect(mockUserRepo.create).toHaveBeenCalledWith(userData)
      expect(mockEmailService.sendWelcomeEmail).toHaveBeenCalledWith(userData.email)
    })
    
    it('should throw error when user already exists', async () => {
      // Arrange
      const userData = { email: 'existing@example.com', name: 'Test', password: 'pass' }
      const mockUserRepo = {
        findByEmail: jest.fn().mockResolvedValue({ id: '1' }),
        create: jest.fn()
      }
      const userService = new UserService(mockUserRepo, mockEmailService, mockLogger)
      
      // Act & Assert
      await expect(userService.createUser(userData))
        .rejects
        .toThrow(ConflictError)
      
      expect(mockUserRepo.create).not.toHaveBeenCalled()
    })
  })
})
\`\`\`

**React Component Testing**
\`\`\`typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { UserProfile } from './UserProfile'

describe('UserProfile', () => {
  const mockUser = {
    id: '1',
    name: 'John Doe',
    email: 'john@example.com',
    avatar: 'avatar.jpg'
  }
  
  it('should display user information', () => {
    render(<UserProfile user={mockUser} onUpdate={jest.fn()} />)
    
    expect(screen.getByText('John Doe')).toBeInTheDocument()
    expect(screen.getByText('john@example.com')).toBeInTheDocument()
    expect(screen.getByRole('img')).toHaveAttribute('src', 'avatar.jpg')
  })
  
  it('should call onUpdate when edit button is clicked', async () => {
    const mockOnUpdate = jest.fn()
    render(<UserProfile user={mockUser} onUpdate={mockOnUpdate} />)
    
    fireEvent.click(screen.getByRole('button', { name: /edit/i }))
    
    await waitFor(() => {
      expect(mockOnUpdate).toHaveBeenCalledWith(mockUser)
    })
  })
})
\`\`\`

### Integration Testing
\`\`\`typescript
describe('User API Integration', () => {
  let app: Application
  let db: Database
  
  beforeAll(async () => {
    app = await createTestApp()
    db = await setupTestDatabase()
  })
  
  afterAll(async () => {
    await db.cleanup()
    await app.close()
  })
  
  beforeEach(async () => {
    await db.clear()
  })
  
  it('should create and retrieve user', async () => {
    const userData = {
      email: 'test@example.com',
      name: 'Test User',
      password: 'password123'
    }
    
    // Create user
    const createResponse = await request(app)
      .post('/api/users')
      .send(userData)
      .expect(201)
    
    const userId = createResponse.body.id
    
    // Retrieve user
    const getResponse = await request(app)
      .get(`/api/users/${userId}`)
      .expect(200)
    
    expect(getResponse.body).toMatchObject({
      id: userId,
      email: userData.email,
      name: userData.name
    })
    expect(getResponse.body.password).toBeUndefined()
  })
})
\`\`\`

### E2E Testing with Playwright
\`\`\`typescript
import { test, expect } from '@playwright/test'

test.describe('User Registration Flow', () => {
  test('should register new user successfully', async ({ page }) => {
    // Navigate to registration page
    await page.goto('/register')
    
    // Fill registration form
    await page.fill('[data-testid="email-input"]', 'test@example.com')
    await page.fill('[data-testid="name-input"]', 'Test User')
    await page.fill('[data-testid="password-input"]', 'password123')
    await page.fill('[data-testid="confirm-password-input"]', 'password123')
    
    // Submit form
    await page.click('[data-testid="register-button"]')
    
    // Verify success
    await expect(page.locator('[data-testid="success-message"]')).toBeVisible()
    await expect(page).toHaveURL('/dashboard')
    
    // Verify user is logged in
    await expect(page.locator('[data-testid="user-menu"]')).toContainText('Test User')
  })
  
  test('should show validation errors for invalid input', async ({ page }) => {
    await page.goto('/register')
    
    // Submit empty form
    await page.click('[data-testid="register-button"]')
    
    // Verify validation errors
    await expect(page.locator('[data-testid="email-error"]')).toContainText('Email is required')
    await expect(page.locator('[data-testid="name-error"]')).toContainText('Name is required')
    await expect(page.locator('[data-testid="password-error"]')).toContainText('Password is required')
  })
})
\`\`\`

---

## Performance Optimization

### Frontend Performance

**Code Splitting & Lazy Loading**
\`\`\`typescript
// Route-based code splitting
const Dashboard = lazy(() => import('./pages/Dashboard'))
const Profile = lazy(() => import('./pages/Profile'))

function App() {
  return (
    <Router>
      <Suspense fallback={<LoadingSpinner />}>
        <Routes>
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/profile" element={<Profile />} />
        </Routes>
      </Suspense>
    </Router>
  )
}

// Component-based code splitting
const HeavyChart = lazy(() => import('./components/HeavyChart'))

function Dashboard() {
  const [showChart, setShowChart] = useState(false)
  
  return (
    <div>
      <h1>Dashboard</h1>
      <button onClick={() => setShowChart(true)}>Show Chart</button>
      {showChart && (
        <Suspense fallback={<ChartSkeleton />}>
          <HeavyChart />
        </Suspense>
      )}
    </div>
  )
}
\`\`\`

**Memoization Strategies**
\`\`\`typescript
// React.memo for component memoization
const UserCard = React.memo(({ user, onEdit }: UserCardProps) => {
  return (
    <div className="user-card">
      <h3>{user.name}</h3>
      <p>{user.email}</p>
      <button onClick={() => onEdit(user)}>Edit</button>
    </div>
  )
})

// useMemo for expensive calculations
function ExpensiveComponent({ data }: { data: number[] }) {
  const expensiveValue = useMemo(() => {
    return data.reduce((acc, val) => acc + Math.sqrt(val), 0)
  }, [data])
  
  return <div>Result: {expensiveValue}</div>
}

// useCallback for stable function references
function UserList({ users }: { users: User[] }) {
  const [selectedUsers, setSelectedUsers] = useState<string[]>([])
  
  const handleUserSelect = useCallback((userId: string) => {
    setSelectedUsers(prev => 
      prev.includes(userId) 
        ? prev.filter(id => id !== userId)
        : [...prev, userId]
    )
  }, [])
  
  return (
    <div>
      {users.map(user => (
        <UserCard 
          key={user.id} 
          user={user} 
          onSelect={handleUserSelect}
        />
      ))}
    </div>
  )
}
\`\`\`

**Virtual Scrolling**
\`\`\`typescript
import { FixedSizeList as List } from 'react-window'

interface VirtualizedListProps {
  items: any[]
  height: number
  itemHeight: number
}

function VirtualizedList({ items, height, itemHeight }: VirtualizedListProps) {
  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => (
    <div style={style}>
      <ItemComponent item={items[index]} />
    </div>
  )
  
  return (
    <List
      height={height}
      itemCount={items.length}
      itemSize={itemHeight}
      width="100%"
    >
      {Row}
    </List>
  )
}
\`\`\`

### Backend Performance

**Database Optimization**
\`\`\`sql
-- Proper indexing
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_posts_user_id ON posts(user_id);
CREATE INDEX idx_posts_created_at ON posts(created_at DESC);

-- Composite indexes for complex queries
CREATE INDEX idx_posts_user_status ON posts(user_id, status, created_at DESC);

-- Partial indexes for filtered queries
CREATE INDEX idx_active_users ON users(email) WHERE status = 'active';
\`\`\`

**Query Optimization**
\`\`\`typescript
// Bad: N+1 query problem
async function getUsersWithPosts() {
  const users = await db.select('*').from('users')
  
  for (const user of users) {
    user.posts = await db.select('*').from('posts').where('user_id', user.id)
  }
  
  return users
}

// Good: Single query with joins
async function getUsersWithPosts() {
  const result = await db
    .select([
      'users.*',
      'posts.id as post_id',
      'posts.title as post_title',
      'posts.content as post_content'
    ])
    .from('users')
    .leftJoin('posts', 'users.id', 'posts.user_id')
  
  // Group results
  const usersMap = new Map()
  
  result.forEach(row => {
    if (!usersMap.has(row.id)) {
      usersMap.set(row.id, {
        id: row.id,
        name: row.name,
        email: row.email,
        posts: []
      })
    }
    
    if (row.post_id) {
      usersMap.get(row.id).posts.push({
        id: row.post_id,
        title: row.post_title,
        content: row.post_content
      })
    }
  })
  
  return Array.from(usersMap.values())
}
\`\`\`

**Caching Strategies**
\`\`\`typescript
// Redis caching layer
class CacheService {
  constructor(private redis: Redis) {}
  
  async get<T>(key: string): Promise<T | null> {
    const cached = await this.redis.get(key)
    return cached ? JSON.parse(cached) : null
  }
  
  async set(key: string, value: any, ttl: number = 3600): Promise<void> {
    await this.redis.setex(key, ttl, JSON.stringify(value))
  }
  
  async invalidate(pattern: string): Promise<void> {
    const keys = await this.redis.keys(pattern)
    if (keys.length > 0) {
      await this.redis.del(...keys)
    }
  }
}

// Service with caching
class UserService {
  constructor(
    private userRepo: UserRepository,
    private cache: CacheService
  ) {}
  
  async getUser(id: string): Promise<User | null> {
    const cacheKey = `user:${id}`
    
    // Try cache first
    let user = await this.cache.get<User>(cacheKey)
    if (user) return user
    
    // Fallback to database
    user = await this.userRepo.findById(id)
    if (user) {
      await this.cache.set(cacheKey, user, 1800) // 30 minutes
    }
    
    return user
  }
  
  async updateUser(id: string, data: UpdateUserData): Promise<User> {
    const user = await this.userRepo.update(id, data)
    
    // Invalidate cache
    await this.cache.invalidate(`user:${id}`)
    
    return user
  }
}
\`\`\`

---

## Security Best Practices

### Authentication & Authorization

**JWT Implementation**
\`\`\`typescript
import jwt from 'jsonwebtoken'
import bcrypt from 'bcrypt'

interface TokenPayload {
  userId: string
  email: string
  role: string
}

class AuthService {
  private readonly JWT_SECRET = process.env.JWT_SECRET!
  private readonly JWT_EXPIRES_IN = '24h'
  private readonly REFRESH_TOKEN_EXPIRES_IN = '7d'
  
  async hashPassword(password: string): Promise<string> {
    const saltRounds = 12
    return bcrypt.hash(password, saltRounds)
  }
  
  async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash)
  }
  
  generateTokens(payload: TokenPayload) {
    const accessToken = jwt.sign(payload, this.JWT_SECRET, {
      expiresIn: this.JWT_EXPIRES_IN
    })
    
    const refreshToken = jwt.sign(payload, this.JWT_SECRET, {
      expiresIn: this.REFRESH_TOKEN_EXPIRES_IN
    })
    
    return { accessToken, refreshToken }
  }
  
  verifyToken(token: string): TokenPayload {
    try {
      return jwt.verify(token, this.JWT_SECRET) as TokenPayload
    } catch (error) {
      throw new UnauthorizedError('Invalid token')
    }
  }
}

// Middleware
function authenticateToken(req: Request, res: Response, next: NextFunction) {
  const authHeader = req.headers.authorization
  const token = authHeader?.split(' ')[1]
  
  if (!token) {
    return res.status(401).json({ error: 'Access token required' })
  }
  
  try {
    const payload = authService.verifyToken(token)
    req.user = payload
    next()
  } catch (error) {
    return res.status(403).json({ error: 'Invalid token' })
  }
}
\`\`\`

**Role-Based Access Control (RBAC)**
\`\`\`typescript
enum Permission {
  READ_USERS = 'read:users',
  WRITE_USERS = 'write:users',
  DELETE_USERS = 'delete:users',
  READ_ADMIN = 'read:admin',
  WRITE_ADMIN = 'write:admin'
}

enum Role {
  USER = 'user',
  MODERATOR = 'moderator',
  ADMIN = 'admin'
}

const ROLE_PERMISSIONS: Record<Role, Permission[]> = {
  [Role.USER]: [Permission.READ_USERS],
  [Role.MODERATOR]: [
    Permission.READ_USERS,
    Permission.WRITE_USERS
  ],
  [Role.ADMIN]: [
    Permission.READ_USERS,
    Permission.WRITE_USERS,
    Permission.DELETE_USERS,
    Permission.READ_ADMIN,
    Permission.WRITE_ADMIN
  ]
}

function hasPermission(userRole: Role, requiredPermission: Permission): boolean {
  return ROLE_PERMISSIONS[userRole].includes(requiredPermission)
}

// Authorization middleware
function requirePermission(permission: Permission) {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Authentication required' })
    }
    
    if (!hasPermission(req.user.role, permission)) {
      return res.status(403).json({ error: 'Insufficient permissions' })
    }
    
    next()
  }
}

// Usage
app.get('/api/users', 
  authenticateToken, 
  requirePermission(Permission.READ_USERS), 
  getUsersHandler
)

app.delete('/api/users/:id', 
  authenticateToken, 
  requirePermission(Permission.DELETE_USERS), 
  deleteUserHandler
)
\`\`\`

### Input Validation & Sanitization

**Schema Validation with Zod**
\`\`\`typescript
import { z } from 'zod'

// Define schemas
const CreateUserSchema = z.object({
  email: z.string().email('Invalid email format'),
  name: z.string().min(2, 'Name must be at least 2 characters').max(50),
  password: z.string()
    .min(8, 'Password must be at least 8 characters')
    .regex(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/, 'Password must contain uppercase, lowercase, and number'),
  age: z.number().int().min(13, 'Must be at least 13 years old').max(120)
})

const UpdateUserSchema = CreateUserSchema.partial().omit({ password: true })

// Validation middleware
function validateBody<T>(schema: z.ZodSchema<T>) {
  return (req: Request, res: Response, next: NextFunction) => {
    try {
      req.body = schema.parse(req.body)
      next()
    } catch (error) {
      if (error instanceof z.ZodError) {
        return res.status(400).json({
          error: 'Validation failed',
          details: error.errors.map(err => ({
            field: err.path.join('.'),
            message: err.message
          }))
        })
      }
      next(error)
    }
  }
}

// Usage
app.post('/api/users', 
  validateBody(CreateUserSchema), 
  createUserHandler
)
\`\`\`

**SQL Injection Prevention**
\`\`\`typescript
// Bad: String concatenation (vulnerable)
async function getUserByEmail(email: string) {
  const query = `SELECT * FROM users WHERE email = '${email}'`
  return db.raw(query)
}

// Good: Parameterized queries
async function getUserByEmail(email: string) {
  return db('users').where('email', email).first()
}

// Good: Raw queries with parameters
async function getComplexUserData(userId: string, status: string) {
  return db.raw(`
    SELECT u.*, COUNT(p.id) as post_count
    FROM users u
    LEFT JOIN posts p ON u.id = p.user_id
    WHERE u.id = ? AND u.status = ?
    GROUP BY u.id
  `, [userId, status])
}
\`\`\`

### CORS & Security Headers

**Security Headers Middleware**
\`\`\`typescript
import helmet from 'helmet'
import cors from 'cors'

// Security headers
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      imgSrc: ["'self'", "data:", "https:"],
      scriptSrc: ["'self'"],
      connectSrc: ["'self'", "https://api.example.com"]
    }
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  }
}))

// CORS configuration
const corsOptions = {
  origin: (origin: string | undefined, callback: Function) => {
    const allowedOrigins = [
      'https://myapp.com',
      'https://www.myapp.com',
      ...(process.env.NODE_ENV === 'development' ? ['http://localhost:3000'] : [])
    ]
    
    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true)
    } else {
      callback(new Error('Not allowed by CORS'))
    }
  },
  credentials: true,
  optionsSuccessStatus: 200
}

app.use(cors(corsOptions))
\`\`\`

### Rate Limiting

**Rate Limiting Implementation**
\`\`\`typescript
import rateLimit from 'express-rate-limit'
import RedisStore from 'rate-limit-redis'
import Redis from 'ioredis'

const redis = new Redis(process.env.REDIS_URL)

// General rate limiting
const generalLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args: string[]) => redis.call(...args)
  }),
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP',
  standardHeaders: true,
  legacyHeaders: false
})

// Strict rate limiting for auth endpoints
const authLimiter = rateLimit({
  store: new RedisStore({
    sendCommand: (...args: string[]) => redis.call(...args)
  }),
  windowMs: 15 * 60 * 1000,
  max: 5, // limit each IP to 5 requests per windowMs
  message: 'Too many authentication attempts',
  skipSuccessfulRequests: true
})

// Apply rate limiting
app.use('/api/', generalLimiter)
app.use('/api/auth/', authLimiter)
\`\`\`

---

## User Experience Principles

### Accessibility (a11y)

**Semantic HTML & ARIA**
\`\`\`typescript
// Good: Semantic HTML with proper ARIA
function SearchForm({ onSearch }: { onSearch: (query: string) => void }) {
  const [query, setQuery] = useState('')
  const [isSearching, setIsSearching] = useState(false)
  
  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setIsSearching(true)
    await onSearch(query)
    setIsSearching(false)
  }
  
  return (
    <form onSubmit={handleSubmit} role="search" aria-label="Search products">
      <div className="search-group">
        <label htmlFor="search-input" className="sr-only">
          Search products
        </label>
        <input
          id="search-input"
          type="search"
          value={query}
          onChange={(e) => setQuery(e.target.value)}
          placeholder="Search products..."
          aria-describedby="search-help"
          aria-required="true"
          disabled={isSearching}
        />
        <div id="search-help" className="sr-only">
          Enter keywords to search for products
        </div>
      </div>
      
      <button 
        type="submit" 
        disabled={!query.trim() || isSearching}
        aria-describedby="search-status"
      >
        {isSearching ? (
          <>
            <span className="spinner" aria-hidden="true" />
            <span className="sr-only">Searching...</span>
          </>
        ) : (
          'Search'
        )}
      </button>
      
      <div id="search-status" className="sr-only" aria-live="polite">
        {isSearching ? 'Searching for products...' : ''}
      </div>
    </form>
  )
}
\`\`\`

**Keyboard Navigation**
\`\`\`typescript
function Modal({ isOpen, onClose, children }: ModalProps) {
  const modalRef = useRef<HTMLDivElement>(null)
  const previousFocusRef = useRef<HTMLElement | null>(null)
  
  useEffect(() => {
    if (isOpen) {
      // Store previously focused element
      previousFocusRef.current = document.activeElement as HTMLElement
      
      // Focus modal
      modalRef.current?.focus()
      
      // Trap focus within modal
      const handleKeyDown = (e: KeyboardEvent) => {
        if (e.key === 'Escape') {
          onClose()
        }
        
        if (e.key === 'Tab') {
          const focusableElements = modalRef.current?.querySelectorAll(
            'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
          )
          
          if (focusableElements && focusableElements.length > 0) {
            const firstElement = focusableElements[0] as HTMLElement
            const lastElement = focusableElements[focusableElements.length - 1] as HTMLElement
            
            if (e.shiftKey && document.activeElement === firstElement) {
              e.preventDefault()
              lastElement.focus()
            } else if (!e.shiftKey && document.activeElement === lastElement) {
              e.preventDefault()
              firstElement.focus()
            }
          }
        }
      }
      
      document.addEventListener('keydown', handleKeyDown)
      
      return () => {
        document.removeEventListener('keydown', handleKeyDown)
        // Restore focus
        previousFocusRef.current?.focus()
      }
    }
  }, [isOpen, onClose])
  
  if (!isOpen) return null
  
  return (
    <div 
      className="modal-overlay" 
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-labelledby="modal-title"
    >
      <div 
        ref={modalRef}
        className="modal-content"
        onClick={(e) => e.stopPropagation()}
        tabIndex={-1}
      >
        <button 
          className="modal-close"
          onClick={onClose}
          aria-label="Close modal"
        >
          ×
        </button>
        {children}
      </div>
    </div>
  )
}
\`\`\`

### Progressive Enhancement

**Loading States & Skeletons**
\`\`\`typescript
function UserProfile({ userId }: { userId: string }) {
  const { data: user, loading, error } = useUser(userId)
  
  if (loading) {
    return <UserProfileSkeleton />
  }
  
  if (error) {
    return (
      <ErrorBoundary 
        error={error} 
        retry={() => window.location.reload()}
      />
    )
  }
  
  if (!user) {
    return <NotFound message="User not found" />
  }
  
  return <UserProfileContent user={user} />
}

function UserProfileSkeleton() {
  return (
    <div className="user-profile-skeleton" aria-label="Loading user profile">
      <div className="skeleton-avatar" />
      <div className="skeleton-text skeleton-text--title" />
      <div className="skeleton-text skeleton-text--subtitle" />
      <div className="skeleton-text skeleton-text--body" />
      <div className="skeleton-text skeleton-text--body" />
    </div>
  )
}
\`\`\`

**Optimistic Updates**
\`\`\`typescript
function useLikePost() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: async ({ postId, liked }: { postId: string; liked: boolean }) => {
      const response = await fetch(`/api/posts/${postId}/like`, {
        method: liked ? 'POST' : 'DELETE'
      })
      if (!response.ok) throw new Error('Failed to update like')
      return response.json()
    },
    
    onMutate: async ({ postId, liked }) => {
      // Cancel outgoing refetches
      await queryClient.cancelQueries(['post', postId])
      
      // Snapshot previous value
      const previousPost = queryClient.getQueryData(['post', postId])
      
      // Optimistically update
      queryClient.setQueryData(['post', postId], (old: any) => ({
        ...old,
        liked,
        likeCount: old.likeCount + (liked ? 1 : -1)
      }))
      
      return { previousPost }
    },
    
    onError: (err, variables, context) => {
      // Rollback on error
      if (context?.previousPost) {
        queryClient.setQueryData(['post', variables.postId], context.previousPost)
      }
    },
    
    onSettled: (data, error, variables) => {
      // Refetch to ensure consistency
      queryClient.invalidateQueries(['post', variables.postId])
    }
  })
}
\`\`\`

### Error Handling & User Feedback

**Error Boundaries**
\`\`\`typescript
interface ErrorBoundaryState {
  hasError: boolean
  error?: Error
}

class ErrorBoundary extends React.Component<
  React.PropsWithChildren<{ fallback?: React.ComponentType<{ error: Error; retry: () => void }> }>,
  ErrorBoundaryState
> {
  constructor(props: any) {
    super(props)
    this.state = { hasError: false }
  }
  
  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error }
  }
  
  componentDidCatch(error: Error, errorInfo: React.ErrorInfo) {
    console.error('Error caught by boundary:', error, errorInfo)
    
    // Log to error reporting service
    errorReportingService.captureException(error, {
      extra: errorInfo,
      tags: { component: 'ErrorBoundary' }
    })
  }
  
  render() {
    if (this.state.hasError) {
      const FallbackComponent = this.props.fallback || DefaultErrorFallback
      
      return (
        <FallbackComponent 
          error={this.state.error!} 
          retry={() => this.setState({ hasError: false, error: undefined })}
        />
      )
    }
    
    return this.props.children
  }
}

function DefaultErrorFallback({ error, retry }: { error: Error; retry: () => void }) {
  return (
    <div className="error-fallback" role="alert">
      <h2>Something went wrong</h2>
      <p>We're sorry, but something unexpected happened.</p>
      <details>
        <summary>Error details</summary>
        <pre>{error.message}</pre>
      </details>
      <button onClick={retry}>Try again</button>
    </div>
  )
}
\`\`\`

**Toast Notifications**
\`\`\`typescript
interface Toast {
  id: string
  type: 'success' | 'error' | 'warning' | 'info'
  title: string
  message?: string
  duration?: number
  action?: {
    label: string
    onClick: () => void
  }
}

function useToast() {
  const [toasts, setToasts] = useState<Toast[]>([])
  
  const addToast = useCallback((toast: Omit<Toast, 'id'>) => {
    const id = Math.random().toString(36).substr(2, 9)
    const newToast = { ...toast, id }
    
    setToasts(prev => [...prev, newToast])
    
    // Auto-remove after duration
    const duration = toast.duration ?? 5000
    if (duration > 0) {
      setTimeout(() => {
        removeToast(id)
      }, duration)
    }
    
    return id
  }, [])
  
  const removeToast = useCallback((id: string) => {
    setToasts(prev => prev.filter(toast => toast.id !== id))
  }, [])
  
  const success = useCallback((title: string, message?: string) => {
    return addToast({ type: 'success', title, message })
  }, [addToast])
  
  const error = useCallback((title: string, message?: string) => {
    return addToast({ type: 'error', title, message, duration: 0 })
  }, [addToast])
  
  return { toasts, addToast, removeToast, success, error }
}
\`\`\`

---

## Project Management & Workflow

### Git Workflow

**Conventional Commits**
\`\`\`bash
# Format: <type>[optional scope]: <description>
# Types: feat, fix, docs, style, refactor, test, chore

git commit -m "feat(auth): add password reset functionality"
git commit -m "fix(api): handle null user in getUserProfile"
git commit -m "docs(readme): update installation instructions"
git commit -m "refactor(components): extract common button styles"
git commit -m "test(auth): add unit tests for login service"
git commit -m "chore(deps): update dependencies to latest versions"
\`\`\`

**Branch Naming Convention**
\`\`\`bash
# Feature branches
git checkout -b feature/user-authentication
git checkout -b feature/payment-integration

# Bug fix branches
git checkout -b fix/login-validation-error
git checkout -b fix/memory-leak-in-dashboard

# Hotfix branches
git checkout -b hotfix/security-vulnerability

# Release branches
git checkout -b release/v1.2.0
\`\`\`

**Pull Request Template**
\`\`\`markdown
## Description
Brief description of changes made.

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed
- [ ] Accessibility testing completed

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Checklist
- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
\`\`\`

### Code Review Guidelines

**Review Checklist**
\`\`\`markdown
## Code Quality
- [ ] Code is readable and well-structured
- [ ] Functions are small and focused (single responsibility)
- [ ] Variable and function names are descriptive
- [ ] No code duplication (DRY principle)
- [ ] Error handling is appropriate
- [ ] Edge cases are considered

## Performance
- [ ] No obvious performance bottlenecks
- [ ] Database queries are optimized
- [ ] Appropriate caching strategies used
- [ ] Bundle size impact considered (for frontend)

## Security
- [ ] Input validation implemented
- [ ] No sensitive data exposed
- [ ] Authentication/authorization properly implemented
- [ ] SQL injection prevention measures in place

## Testing
- [ ] Adequate test coverage
- [ ] Tests are meaningful and test the right things
- [ ] Tests are maintainable
- [ ] Edge cases are tested

## Documentation
- [ ] Code is self-documenting or properly commented
- [ ] API documentation updated (if applicable)
- [ ] README updated (if applicable)
\`\`\`

### CI/CD Pipeline

**GitHub Actions Workflow**
\`\`\`yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: test_db
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - name: Install dependencies
        run: npm ci
      
      - name: Run linting
        run: npm run lint
      
      - name: Run type checking
        run: npm run type-check
      
      - name: Run unit tests
        run: npm run test:unit
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
      
      - name: Run integration tests
        run: npm run test:integration
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db
      
      - name: Build application
        run: npm run build
      
      - name: Run E2E tests
        run: npm run test:e2e
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost:5432/test_db

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Vercel
        uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'
\`\`\`

---

## Debugging & Troubleshooting

### Debugging Strategies

**Systematic Debugging Approach**
\`\`\`typescript
// 1. Reproduce the issue consistently
function debugUserLogin(email: string, password: string) {
  console.log('[DEBUG] Login attempt:', { email, timestamp: new Date().toISOString() })
  
  try {
    // 2. Add logging at key points
    const user = await userService.findByEmail(email)
    console.log('[DEBUG] User found:', { userId: user?.id, userExists: !!user })
    
    if (!user) {
      console.log('[DEBUG] Login failed: User not found')
      throw new NotFoundError('User not found')
    }
    
    const isValidPassword = await authService.verifyPassword(password, user.passwordHash)
    console.log('[DEBUG] Password validation:', { isValid: isValidPassword })
    
    if (!isValidPassword) {
      console.log('[DEBUG] Login failed: Invalid password')
      throw new UnauthorizedError('Invalid credentials')
    }
    
    const tokens = authService.generateTokens({
      userId: user.id,
      email: user.email,
      role: user.role
    })
    
    console.log('[DEBUG] Login successful:', { userId: user.id })
    return tokens
    
  } catch (error) {
    console.error('[DEBUG] Login error:', {
      error: error.message,
      stack: error.stack,
      email,
      timestamp: new Date().toISOString()
    })
    throw error
  }
}
\`\`\`

**Error Tracking & Monitoring**
\`\`\`typescript
// Error reporting service integration
class ErrorReportingService {
  constructor(private apiKey: string) {}
  
  captureException(error: Error, context?: {
    user?: { id: string; email: string }
    extra?: Record<string, any>
    tags?: Record<string, string>
  }) {
    const errorData = {
      message: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString(),
      url: window.location.href,
      userAgent: navigator.userAgent,
      ...context
    }
    
    // Send to error tracking service (Sentry, Bugsnag, etc.)
    fetch('/api/errors', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(errorData)
    }).catch(console.error)
  }
  
  captureMessage(message: string, level: 'info' | 'warning' | 'error' = 'info') {
    const logData = {
      message,
      level,
      timestamp: new Date().toISOString(),
      url: window.location.href
    }
    
    fetch('/api/logs', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(logData)
    }).catch(console.error)
  }
}

// Global error handlers
window.addEventListener('error', (event) => {
  errorReportingService.captureException(event.error)
})

window.addEventListener('unhandledrejection', (event) => {
  errorReportingService.captureException(new Error(event.reason))
})
\`\`\`

### Performance Debugging

**Performance Monitoring**
\`\`\`typescript
// Performance measurement utilities
class PerformanceMonitor {
  private static measurements: Map<string, number> = new Map()
  
  static start(label: string) {
    this.measurements.set(label, performance.now())
  }
  
  static end(label: string): number {
    const startTime = this.measurements.get(label)
    if (!startTime) {
      console.warn(`No start time found for ${label}`)
      return 0
    }
    
    const duration = performance.now() - startTime
    this.measurements.delete(label)
    
    console.log(`[PERF] ${label}: ${duration.toFixed(2)}ms`)
    
    // Send to analytics if duration is significant
    if (duration > 1000) {
      analytics.track('Performance Issue', {
        operation: label,
        duration,
        url: window.location.href
      })
    }
    
    return duration
  }
  
  static async measure<T>(label: string, fn: () => Promise<T>): Promise<T> {
    this.start(label)
    try {
      const result = await fn()
      return result
    } finally {
      this.end(label)
    }
  }
}

// Usage
async function loadUserDashboard(userId: string) {
  return PerformanceMonitor.measure('loadUserDashboard', async () => {
    PerformanceMonitor.start('fetchUser')
    const user = await userService.getUser(userId)
    PerformanceMonitor.end('fetchUser')
    
    PerformanceMonitor.start('fetchUserPosts')
    const posts = await postService.getUserPosts(userId)
    PerformanceMonitor.end('fetchUserPosts')
    
    return { user, posts }
  })
}
\`\`\`

**Memory Leak Detection**
\`\`\`typescript
// Memory usage monitoring
class MemoryMonitor {
  private static interval: NodeJS.Timeout | null = null
  
  static start() {
    if (this.interval) return
    
    this.interval = setInterval(() => {
      if ('memory' in performance) {
        const memory = (performance as any).memory
        const used = Math.round(memory.usedJSHeapSize / 1048576 * 100) / 100
        const total = Math.round(memory.totalJSHeapSize / 1048576 * 100) / 100
        
        console.log(`[MEMORY] Used: ${used}MB, Total: ${total}MB`)
        
        // Alert if memory usage is high
        if (used > 100) {
          console.warn('[MEMORY] High memory usage detected')
          errorReportingService.captureMessage(
            `High memory usage: ${used}MB`,
            'warning'
          )
        }
      }
    }, 30000) // Check every 30 seconds
  }
  
  static stop() {
    if (this.interval) {
      clearInterval(this.interval)
      this.interval = null
    }
  }
}

// React component memory leak detection
function useMemoryLeakDetection(componentName: string) {
  useEffect(() => {
    console.log(`[MEMORY] ${componentName} mounted`)
    
    return () => {
      console.log(`[MEMORY] ${componentName} unmounted`)
      
      // Check for potential memory leaks
      setTimeout(() => {
        if ('memory' in performance) {
          const memory = (performance as any).memory
          const used = Math.round(memory.usedJSHeapSize / 1048576 * 100) / 100
          
          if (used > 50) {
            console.warn(`[MEMORY] Potential leak after ${componentName} unmount: ${used}MB`)
          }
        }
      }, 1000)
    }
  }, [componentName])
}
\`\`\`

---

## Continuous Learning & Improvement

### Code Review & Feedback

**Self-Review Checklist**
\`\`\`markdown
## Before Submitting Code

### Functionality
- [ ] Does the code solve the intended problem?
- [ ] Are all edge cases handled?
- [ ] Is error handling comprehensive?
- [ ] Are there any potential race conditions?

### Code Quality
- [ ] Is the code readable and self-documenting?
- [ ] Are functions small and focused?
- [ ] Is there any code duplication?
- [ ] Are variable names descriptive?
- [ ] Is the code consistent with project conventions?

### Performance
- [ ] Are there any obvious performance issues?
- [ ] Is the solution efficient?
- [ ] Are expensive operations cached or memoized?
- [ ] Is the bundle size impact acceptable?

### Security
- [ ] Is user input properly validated?
- [ ] Are there any potential security vulnerabilities?
- [ ] Is sensitive data properly protected?
- [ ] Are authentication/authorization checks in place?

### Testing
- [ ] Are there adequate tests?
- [ ] Do tests cover edge cases?
- [ ] Are tests maintainable and readable?
- [ ] Do all tests pass?

### Documentation
- [ ] Is the code self-documenting?
- [ ] Are complex algorithms explained?
- [ ] Is API documentation updated?
- [ ] Are breaking changes documented?
\`\`\`

### Learning Resources & Best Practices

**Staying Current**
\`\`\`markdown
## Daily Learning Routine

### Technical Reading (15-30 min/day)
- [ ] Read one technical article or blog post
- [ ] Follow key developers and thought leaders on Twitter/LinkedIn
- [ ] Subscribe to relevant newsletters (JavaScript Weekly, React Status, etc.)
- [ ] Browse GitHub trending repositories

### Hands-on Practice (30-60 min/day)
- [ ] Work on personal projects
- [ ] Contribute to open source projects
- [ ] Practice coding challenges (LeetCode, CodeWars)
- [ ] Experiment with new technologies

### Community Engagement
- [ ] Participate in developer communities (Reddit, Discord, Stack Overflow)
- [ ] Attend virtual meetups and conferences
- [ ] Share knowledge through blog posts or talks
- [ ] Mentor junior developers

### Reflection & Documentation
- [ ] Keep a learning journal
- [ ] Document lessons learned from projects
- [ ] Maintain a personal knowledge base
- [ ] Regular skill assessment and goal setting
\`\`\`

**Technology Evaluation Framework**
\`\`\`markdown
## Evaluating New Technologies

### Initial Assessment
- [ ] What problem does this technology solve?
- [ ] How does it compare to existing solutions?
- [ ] What is the learning curve?
- [ ] Is it actively maintained?
- [ ] What is the community size and support?

### Technical Evaluation
- [ ] Performance characteristics
- [ ] Security considerations
- [ ] Integration complexity
- [ ] Scalability potential
- [ ] Documentation quality

### Business Considerations
- [ ] Development time impact
- [ ] Maintenance overhead
- [ ] Team skill requirements
- [ ] Long-term viability
- [ ] Cost implications

### Decision Matrix
Rate each factor (1-5) and calculate weighted score:
- Problem fit: ___/5 (weight: 25%)
- Technical merit: ___/5 (weight: 20%)
- Team readiness: ___/5 (weight: 20%)
- Community support: ___/5 (weight: 15%)
- Business value: ___/5 (weight: 20%)

Total Score: ___/5
Decision: [ ] Adopt [ ] Trial [ ] Assess [ ] Hold
\`\`\`

---

## AI-Assisted Development

### Effective AI Prompting

**Prompt Engineering for Code Generation**
\`\`\`markdown
## Effective AI Prompting Strategies

### Context Setting
Always provide:
- Programming language and framework
- Specific requirements and constraints
- Expected input/output format
- Error handling requirements
- Performance considerations

### Example Prompts

#### Good Prompt
"Create a TypeScript React component for a user profile card that:
- Accepts user data (name, email, avatar, role) as props
- Shows a loading state while avatar loads
- Handles missing avatar with fallback initials
- Includes edit and delete action buttons
- Uses Tailwind CSS for styling
- Follows accessibility best practices
- Includes proper TypeScript interfaces"

#### Bad Prompt
"Make a user component"

### Iterative Refinement
1. Start with basic requirements
2. Add specific constraints and edge cases
3. Request optimizations and improvements
4. Ask for alternative approaches
5. Validate and test the solution
\`\`\`

**AI-Assisted Code Review**
\`\`\`typescript
// Use AI to help with code review by asking specific questions:

/*
AI Prompt: "Review this TypeScript function for:
1. Potential bugs or edge cases
2. Performance optimizations
3. Security vulnerabilities
4. Code readability improvements
5. TypeScript best practices

Function:
*/

async function updateUserProfile(userId: string, updates: Partial<User>): Promise<User> {
  const user = await db.users.findUnique({ where: { id: userId } })
  
  if (!user) {
    throw new Error('User not found')
  }
  
  const updatedUser = await db.users.update({
    where: { id: userId },
    data: updates
  })
  
  return updatedUser
}

/*
Expected AI feedback on:
- Input validation missing
- Error handling could be more specific
- No authorization checks
- Potential for SQL injection if using raw queries
- Missing transaction handling for complex updates
*/
\`\`\`

### AI-Powered Development Workflow

**Development Process with AI**
\`\`\`markdown
## AI-Enhanced Development Workflow

### 1. Planning Phase
- Use AI to brainstorm architecture approaches
- Generate user stories and acceptance criteria
- Create technical specifications
- Identify potential challenges and solutions

### 2. Implementation Phase
- Generate boilerplate code and scaffolding
- Create utility functions and helpers
- Implement complex algorithms
- Generate test cases and mock data

### 3. Review Phase
- Code review and optimization suggestions
- Security vulnerability analysis
- Performance improvement recommendations
- Documentation generation

### 4. Testing Phase
- Generate unit test cases
- Create integration test scenarios
- Generate test data and fixtures
- Identify edge cases to test

### 5. Documentation Phase
- Generate API documentation
- Create user guides and tutorials
- Write technical specifications
- Generate code comments and explanations
\`\`\`

---

## Team Collaboration

### Communication Best Practices

**Technical Communication**
\`\`\`markdown
## Effective Technical Communication

### Code Comments
\`\`\`typescript
// Good: Explains WHY, not WHAT
// Cache user permissions for 5 minutes to reduce database load
// during high-traffic periods when users navigate between pages
const userPermissions = await cacheService.get(
  `permissions:${userId}`, 
  () => permissionService.getUserPermissions(userId),
  300 // 5 minutes
)

// Bad: Explains WHAT (obvious from code)
// Get user permissions from cache
const userPermissions = await cacheService.get(...)
\`\`\`

### Documentation Standards
- Write for your future self and teammates
- Include examples and use cases
- Document assumptions and limitations
- Keep documentation close to code
- Update docs with code changes

### Code Review Communication
- Be constructive and specific
- Explain the "why" behind suggestions
- Offer alternatives when pointing out issues
- Acknowledge good practices
- Ask questions to understand context
\`\`\`

**Knowledge Sharing**
\`\`\`markdown
## Team Knowledge Sharing

### Regular Practices
- Weekly tech talks or demos
- Code review sessions
- Architecture decision records (ADRs)
- Post-mortem meetings for incidents
- Pair programming sessions

### Documentation
- Maintain team wiki or knowledge base
- Document common patterns and solutions
- Share learning resources and articles
- Create troubleshooting guides
- Maintain coding standards document

### Mentoring
- Pair junior developers with seniors
- Regular one-on-one technical discussions
- Code review as teaching opportunity
- Encourage questions and experimentation
- Share conference talks and articles
\`\`\`

---

## Conclusion

This comprehensive guide represents a systematic approach to building high-quality software. The key principles to remember:

1. **Start with solid foundations** - Architecture, typing, and patterns
2. **Prioritize code quality** - Readability, maintainability, and testability
3. **Think about users first** - Performance, accessibility, and experience
4. **Build for the team** - Documentation, standards, and collaboration
5. **Never stop learning** - Stay current, experiment, and share knowledge

Remember: Great software is not just about writing code that works, but writing code that can be understood, maintained, and evolved by your team over time.

The best developers combine technical excellence with strong communication skills, continuous learning mindset, and a focus on delivering value to users and stakeholders.

---

*"Any fool can write code that a computer can understand. Good programmers write code that humans can understand."* - Martin Fowler
