# React + TypeScript + Vite + Flask Directory Structure

## Recommended Project Structure

```
project-root/
├── frontend/                 # React + TypeScript + Vite
│   ├── public/
│   │   ├── index.html
│   │   └── favicon.ico
│   ├── src/
│   │   ├── components/       # Reusable UI components
│   │   │   ├── ui/          # Basic UI components
│   │   │   └── forms/       # Form components
│   │   ├── pages/           # Route-level components
│   │   ├── hooks/           # Custom React hooks
│   │   ├── services/        # API calls and external services
│   │   ├── types/           # TypeScript type definitions
│   │   ├── utils/           # Utility functions
│   │   ├── store/           # State management (Redux/Zustand)
│   │   ├── styles/          # Global styles and themes
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── package.json
│   ├── vite.config.ts
│   ├── tsconfig.json
│   └── tailwind.config.js   # If using Tailwind
├── backend/                  # Flask API
│   ├── app/
│   │   ├── __init__.py      # Flask app factory
│   │   ├── models/          # Database models
│   │   ├── routes/          # API route handlers
│   │   ├── services/        # Business logic
│   │   ├── utils/           # Utility functions
│   │   └── config.py        # Configuration settings
│   ├── migrations/          # Database migrations
│   ├── tests/
│   ├── requirements.txt
│   └── run.py              # Application entry point
├── shared/                  # Shared resources
│   ├── types/              # Shared TypeScript types
│   └── schemas/            # API schemas/validation
├── docker-compose.yml      # Local development setup
├── .gitignore
└── README.md
```

## Directory Explanations

### Frontend (`/frontend`)
- **React + TypeScript + Vite** setup for modern, fast development
- **`src/components/`**: Reusable UI components organized by type
- **`src/pages/`**: Route-level components that compose the main views
- **`src/hooks/`**: Custom React hooks for shared logic
- **`src/services/`**: API client code and external service integrations
- **`src/types/`**: TypeScript type definitions specific to frontend
- **`src/store/`**: State management (Redux Toolkit, Zustand, etc.)
- **`vite.config.ts`**: Vite configuration for build optimization

### Backend (`/backend`)
- **Flask** API with modular structure
- **`app/models/`**: Database models (SQLAlchemy)
- **`app/routes/`**: API endpoints organized by feature
- **`app/services/`**: Business logic separated from route handlers
- **`migrations/`**: Database schema migrations
- **`tests/`**: Backend unit and integration tests

### Shared (`/shared`)
- **Cross-platform code** used by both frontend and backend
- **`types/`**: TypeScript interfaces for API contracts
- **`schemas/`**: Validation schemas (Pydantic, Zod)

## Key Benefits

1. **Separation of Concerns**: Frontend and backend are clearly separated
2. **Scalability**: Each layer can be developed and deployed independently
3. **TypeScript Integration**: Shared types ensure API contract consistency
4. **Modern Tooling**: Vite provides fast development builds, Flask offers flexible API development
5. **Testing**: Separate test directories for each layer
6. **Docker Support**: Easy local development and deployment
7. **Team Collaboration**: Structure supports independent development teams

## Development Workflow

1. **Backend First**: Define API endpoints and data models
2. **Shared Types**: Create TypeScript interfaces for API contracts
3. **Frontend Integration**: Build UI components that consume the API
4. **Testing**: Write tests for both layers independently
5. **Deployment**: Use Docker for consistent environments across development and production