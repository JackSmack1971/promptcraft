# PromptCraft Development Guide for AI Agents

## Project Overview

PromptCraft is an AI-powered prompt engineering platform designed for novice users, featuring intelligent templates, guided workflows, and real-time improvement suggestions. The platform integrates with multiple AI providers (OpenAI, Anthropic, Google) and focuses on making prompt engineering accessible to non-technical users.

### Key Architecture Components
- **Frontend**: React 18.x + TypeScript + Tailwind CSS + Zustand
- **Backend**: Node.js 20.x + Express.js + TypeScript
- **Database**: PostgreSQL 15.x + Redis 7.x for caching
- **AI Integration**: Multi-provider abstraction layer using Model Context Protocol (MCP)
- **Deployment**: Docker + Kubernetes, Vercel for frontend

## Project Structure & Navigation

```
promptcraft/
├── frontend/                 # React application
│   ├── src/
│   │   ├── components/      # Reusable UI components
│   │   │   ├── auth/        # Authentication forms
│   │   │   ├── templates/   # Template management
│   │   │   ├── prompts/     # Prompt editor and execution
│   │   │   ├── wizard/      # Guided prompt builder
│   │   │   └── common/      # Shared components
│   │   ├── pages/           # Main application pages
│   │   ├── stores/          # Zustand state management
│   │   ├── hooks/           # Custom React hooks
│   │   └── utils/           # Utility functions
├── backend/                 # Node.js API server
│   ├── routes/              # API route handlers
│   ├── services/            # Business logic layer
│   │   ├── openaiService.js     # OpenAI API integration
│   │   ├── anthropicService.js  # Anthropic API integration
│   │   ├── geminiService.js     # Google Gemini integration
│   │   └── aiProviderService.js # Multi-provider abstraction
│   ├── models/              # Database models and schemas
│   ├── middleware/          # Express middleware
│   └── utils/               # Backend utilities
├── database/
│   ├── migrations/          # Database schema changes
│   └── seeds/               # Test data and initial templates
├── docs/                    # Project documentation
└── scripts/                 # Deployment and utility scripts
```

### Quick Navigation Commands
- `find . -name "*.tsx" -path "*/components/prompts/*"` - Find prompt-related components
- `find . -name "*Service.js" -path "*/services/*"` - Locate service layer files
- `grep -r "TASK-" . --include="*.md"` - Find task references in documentation

## Development Environment & Setup

### Environment Configuration
```bash
# Required environment variables
OPENAI_API_KEY=your_openai_key
ANTHROPIC_API_KEY=your_anthropic_key  
GOOGLE_AI_API_KEY=your_google_key
DATABASE_URL=postgresql://user:pass@localhost:5432/promptcraft
REDIS_URL=redis://localhost:6379
JWT_SECRET=your_jwt_secret
NODE_ENV=development
```

### Database Setup
```bash
# Run migrations
npm run migrate:up

# Seed development data
npm run seed:dev

# Reset database (development only)
npm run db:reset
```

### Development Commands
```bash
# Start development servers
npm run dev              # Starts both frontend and backend
npm run dev:frontend     # Frontend only (port 3000)
npm run dev:backend      # Backend only (port 8000)

# Testing
npm run test             # Run all tests
npm run test:frontend    # Frontend tests only
npm run test:backend     # Backend tests only
npm run test:e2e         # End-to-end tests

# Code quality
npm run lint             # ESLint + Prettier
npm run type-check       # TypeScript validation
npm run security-audit   # Security vulnerability scan
```

## Development Guidelines

### Code Standards
- **TypeScript**: Strict mode enabled, explicit return types for functions
- **React**: Functional components with hooks, memo for performance optimization
- **API**: RESTful design with OpenAPI 3.0 documentation
- **Database**: Use Prisma ORM for type-safe database operations
- **Error Handling**: Centralized error handling with correlation IDs

### Component Architecture Patterns
```typescript
// Preferred component structure
interface ComponentProps {
  // Explicit prop types
}

export const Component: React.FC<ComponentProps> = ({ prop1, prop2 }) => {
  // Hooks at top
  const [state, setState] = useState<Type>();
  const { data, loading } = useQuery();
  
  // Event handlers
  const handleEvent = useCallback(() => {
    // Implementation
  }, [dependencies]);
  
  // Early returns for loading/error states
  if (loading) return <LoadingSkeleton />;
  if (error) return <ErrorBoundary error={error} />;
  
  return (
    // JSX with proper accessibility
  );
};
```

### AI Provider Integration Patterns
```javascript
// All AI provider services should implement this interface
class AIProviderService {
  async executePrompt(prompt, options) {
    // Standardized execution method
  }
  
  async analyzePrompt(prompt) {
    // Common analysis interface
  }
  
  calculateCost(tokens) {
    // Provider-specific cost calculation
  }
}
```

## Task Execution Guidelines

### For Authentication Tasks (TASK-003, TASK-004, TASK-005)
- Implement JWT with refresh token rotation
- Use bcrypt with salt rounds >= 12 for password hashing
- Add rate limiting (5 attempts per 15 minutes) for login endpoints
- Include correlation IDs for request tracing

### For AI Integration Tasks (TASK-008, TASK-015, TASK-016, TASK-017)
- Follow the adapter pattern for provider abstraction
- Implement exponential backoff for rate limiting
- Use circuit breaker pattern for API failures
- Track usage metrics: tokens, cost, response time
- Store API keys securely in environment variables

### For Frontend Tasks (TASK-010, TASK-011, TASK-012, TASK-013)
- Use Zustand for global state management
- Implement React Hook Form for form validation
- Follow mobile-first responsive design principles
- Add loading states and error boundaries
- Ensure WCAG 2.1 AA accessibility compliance

### For Template Management (TASK-006, TASK-007)
- Use PostgreSQL tsvector for full-text search
- Implement proper indexing on search columns
- Add pagination with cursor-based navigation
- Cache frequently accessed templates in Redis

## Testing Strategy

### Unit Tests
- **Coverage Target**: 90% for business logic, 80% for UI components
- **Tools**: Jest + React Testing Library for frontend, Jest + Supertest for backend
- **Pattern**: Arrange-Act-Assert with descriptive test names

### Integration Tests
- **Database**: Use test database with transaction rollback
- **AI Providers**: Mock external APIs, test integration patterns
- **Authentication**: Test JWT flows and authorization middleware

### End-to-End Tests
- **Framework**: Playwright for cross-browser testing
- **Scenarios**: Critical user journeys from registration to prompt execution
- **Data**: Use seeded test data, clean up after tests

### Performance Tests
- **Load Testing**: Artillery for API endpoints
- **Frontend**: Lighthouse CI for performance metrics
- **Database**: Query performance analysis with EXPLAIN ANALYZE

## Validation & Quality Assurance

### Before Committing Code
```bash
# Run the full validation suite
npm run validate

# This includes:
# - TypeScript compilation
# - ESLint + Prettier formatting
# - Unit tests with coverage
# - Security audit
# - Build verification
```

### Database Changes
- Always create reversible migrations
- Test migrations on staging data
- Add appropriate indexes for new queries
- Update seed data if schema changes affect it

### API Changes
- Update OpenAPI documentation
- Maintain backward compatibility where possible
- Add integration tests for new endpoints
- Document breaking changes in CHANGELOG.md

### AI Provider Integration
- Test against staging/sandbox environments first
- Validate response parsing for edge cases
- Implement proper error handling for API failures
- Test rate limiting and fallback mechanisms

## Security Considerations

### API Security
- Validate all inputs with joi or similar library
- Sanitize user-generated content (especially prompts)
- Implement CORS with appropriate origin restrictions
- Use helmet.js for security headers

### Data Protection
- Encrypt sensitive data at rest (API keys, user prompts)
- Use TLS 1.3 for all external communications
- Implement proper session management with Redis
- Add audit logging for sensitive operations

### AI Provider Security
- Never log API keys or responses containing user data
- Implement request/response sanitization
- Use separate API keys for different environments
- Monitor for unusual usage patterns

## Performance Optimization

### Frontend Performance
- Use React.memo and useMemo strategically
- Implement code splitting at route level
- Optimize bundle size with tree shaking
- Use Tailwind's purge for minimal CSS

### Backend Performance
- Implement response caching with Redis
- Use connection pooling for database
- Add database query optimization
- Monitor API response times with New Relic/Datadog

### Database Optimization
- Use appropriate indexes for search queries
- Implement query optimization for template discovery
- Use read replicas for heavy read operations
- Monitor slow query logs

## Work Presentation Standards

### Commit Messages
```
feat(auth): implement JWT refresh token rotation

- Add refresh token table and migration
- Implement token rotation on authentication
- Add middleware for automatic token refresh
- Update frontend auth store for token handling

Closes: TASK-005
```

### Pull Request Guidelines
- **Title**: `[TASK-XXX] Brief description of changes`
- **Description**: 
  - Summary of changes made
  - Link to related task/issue
  - Testing approach used
  - Any breaking changes or migration notes
- **Review**: Require approval from tech lead for architecture changes

### Documentation Updates
- Update API documentation for endpoint changes
- Add JSDoc comments for complex functions
- Update README.md for environment setup changes
- Document new patterns in this AGENTS.md file

## Deployment & Infrastructure

### Staging Deployment
- Automatic deployment on merge to `develop` branch
- Run full test suite before deployment
- Use staging environment variables and test data
- Validate AI provider integrations work correctly

### Production Deployment
- Manual approval required for production releases
- Blue-green deployment strategy with health checks
- Database migrations run before application deployment
- Monitor deployment metrics and error rates

### Environment Management
- Use separate AI provider accounts for each environment
- Implement proper secrets management with Docker secrets
- Monitor resource usage and scaling metrics
- Set up alerts for system health and performance

## Troubleshooting Common Issues

### AI Provider Integration Issues
- **Rate Limiting**: Check exponential backoff implementation
- **Authentication Errors**: Verify API key configuration
- **Response Parsing**: Test with provider-specific response formats
- **Timeouts**: Adjust timeout values and implement proper error handling

### Database Issues
- **Migration Failures**: Check for conflicting schema changes
- **Query Performance**: Use EXPLAIN ANALYZE for slow queries
- **Connection Issues**: Verify connection pooling configuration

### Frontend Issues
- **State Management**: Check Zustand store updates and subscriptions
- **Routing**: Verify React Router configuration and protected routes
- **Performance**: Use React DevTools Profiler for component analysis

### Authentication Issues
- **JWT Errors**: Check token expiration and signing secret
- **Session Management**: Verify Redis connection and session storage
- **Rate Limiting**: Review rate limiter configuration and Redis state

## Project-Specific Context

### Target Users
- **Primary**: Non-technical business users (marketing managers, small business owners, HR coordinators)
- **Secondary**: Technical users seeking efficiency improvements
- **Design Philosophy**: Novice-first with progressive disclosure of advanced features

### Key Differentiators
1. **Guided Prompt Builder**: Step-by-step wizard for prompt creation
2. **Real-time AI Suggestions**: Live feedback and improvement recommendations
3. **Multi-Provider Comparison**: Side-by-side testing across OpenAI, Anthropic, Google
4. **Template Library**: Curated, industry-specific prompt templates

### Performance Targets
- **API Response Time**: <200ms P95 for CRUD operations
- **AI Execution**: <30 seconds with proper timeout handling
- **Frontend Load**: <2 seconds for initial page load
- **Concurrent Users**: Support 1,000 users without degradation

### Success Metrics
- **User Adoption**: 10,000 active users within 12 months
- **User Success**: 85% achieve improved AI results within first week
- **Time to Value**: 15 minutes from signup to first successful prompt
- **Retention**: 70% monthly active user retention

---

## Quick Reference Commands

```bash
# Start development
npm run dev

# Run specific tests
npm run test:auth          # Authentication tests
npm run test:ai            # AI provider integration tests
npm run test:templates     # Template management tests

# Database operations
npm run migrate:up         # Apply migrations
npm run migrate:down       # Rollback last migration
npm run seed:templates     # Seed template library

# Build and deploy
npm run build              # Production build
npm run docker:build       # Build Docker images
npm run deploy:staging     # Deploy to staging

# Monitoring and debugging
npm run logs:backend       # View backend logs
npm run db:console         # Access database console
npm run redis:console      # Access Redis console
```

Remember: This project focuses on making AI accessible to novice users. When implementing features, always consider the user experience from a non-technical perspective and prioritize clarity, guidance, and error prevention over advanced functionality.
