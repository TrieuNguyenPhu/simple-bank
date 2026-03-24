# AI Documentation

This directory contains comprehensive documentation optimized for AI agents and developers working with the Simple Bank codebase.

## 📚 Documentation Structure

### [PROJECT_CONTEXT.md](./PROJECT_CONTEXT.md)
**Purpose**: High-level project overview  
**Contains**: Tech stack, domain model, deployment context, key architectural decisions, and project origin  
**Read first when**: Starting work on the project or onboarding new team members

### [ARCHITECTURE.md](./ARCHITECTURE.md)
**Purpose**: System design and component interactions  
**Contains**: Process architecture, layer breakdown, data flows, middleware chain, concurrency patterns  
**Read first when**: Understanding system structure, adding new features, or troubleshooting integration issues

### [API_MAP.md](./API_MAP.md)
**Purpose**: Complete API reference  
**Contains**: All endpoints (gRPC + HTTP), request/response schemas, authentication requirements, error formats  
**Read first when**: Integrating with APIs, implementing new endpoints, or debugging API issues

### [BUSINESS_RULES.md](./BUSINESS_RULES.md)
**Purpose**: Domain logic and constraints  
**Contains**: User management rules, transfer logic, authorization matrix, validation rules, data invariants  
**Read first when**: Implementing business logic, validating requirements, or ensuring compliance

### [AI_NOTES.md](./AI_NOTES.md)
**Purpose**: Practical development guide  
**Contains**: Quick start, code generation workflows, common gotchas, file locations, Makefile commands  
**Read first when**: Making code changes, running tests, or performing common development tasks

## 🎯 Quick Navigation

**I want to...**
- **Understand the project** → Start with PROJECT_CONTEXT.md
- **Add a new API endpoint** → Read ARCHITECTURE.md + API_MAP.md, then AI_NOTES.md (Adding New RPC)
- **Modify database schema** → Check BUSINESS_RULES.md, then AI_NOTES.md (Adding DB Table/Column)
- **Implement business logic** → Read BUSINESS_RULES.md + ARCHITECTURE.md (Business Logic Layer)
- **Debug authentication** → See API_MAP.md (Token Types) + AI_NOTES.md (Authentication Flow)
- **Run tests or deploy** → Check AI_NOTES.md (Testing Strategy, Makefile Commands)

## 🔄 Maintenance Guidelines

### When to Update These Docs

**Update immediately when**:
- Adding/removing API endpoints
- Changing business rules or validation logic
- Modifying authentication/authorization flow
- Altering database schema or constraints
- Changing deployment architecture

**No update needed for**:
- Implementation details (function signatures, variable names)
- Bug fixes that don't change behavior
- Code refactoring without logic changes
- Dependency version updates
- Performance optimizations

### How to Update

1. **Identify affected documents**: Most changes affect 1-2 docs
2. **Update specific sections**: Don't rewrite entire files
3. **Keep it concise**: Focus on "what" and "why", not "how"
4. **Maintain consistency**: Use same terminology across all docs
5. **Test AI comprehension**: Ensure changes are clear to AI agents

## 📖 Documentation Philosophy

These documents follow principles optimized for AI agent comprehension:

1. **Stable over volatile**: Focus on architectural patterns, not implementation details
2. **Structured over prose**: Use tables, lists, and code blocks for clarity
3. **Complete over minimal**: Include all information needed to work autonomously
4. **Practical over theoretical**: Provide actionable guidance with examples
5. **Layered complexity**: Start simple, add detail progressively

## 🤖 For AI Agents

When working with this codebase:

1. **Always read PROJECT_CONTEXT.md first** to understand the domain and tech stack
2. **Reference multiple docs** for complex tasks (e.g., adding authenticated endpoint needs API_MAP + BUSINESS_RULES + AI_NOTES)
3. **Check AI_NOTES.md for gotchas** before making database or auth changes
4. **Follow code generation workflows** exactly as specified
5. **Validate business rules** from BUSINESS_RULES.md before implementing features

## 📝 Document Versions

| Document | Last Major Update | Focus Area |
|----------|-------------------|------------|
| PROJECT_CONTEXT.md | Initial | Project overview |
| ARCHITECTURE.md | Initial | System design |
| API_MAP.md | Initial | API reference |
| BUSINESS_RULES.md | Initial | Domain logic |
| AI_NOTES.md | Initial | Development guide |

---

**Note**: These documents complement, not replace, code comments and inline documentation. Always check source code for implementation-specific details.
