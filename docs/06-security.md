# Security Policy

## Principles

1. **The client is never trusted.** All game state changes are validated server-side.
2. **Secrets never enter the repository.** Use environment variables and CI secrets.
3. **Defense in depth.** Multiple layers of validation, not a single point of trust.
4. **Least privilege.** Each component accesses only what it needs.

## Authoritative Server

The server is the single source of truth for all game state:

| What the client sends    | What the server does                        |
|--------------------------|---------------------------------------------|
| Input direction          | Validates speed/position, applies movement  |
| Attack intent            | Checks range, cooldowns, calculates damage  |
| Item use request         | Verifies inventory, applies effects         |
| Trade request            | Validates both parties' inventories         |
| Chat message             | Rate-limits, filters, broadcasts            |

### What the server NEVER accepts from a client:
- "I dealt X damage"
- "I'm at position (X,Y)" without validation
- "I have item X in my inventory"
- "My health is X"
- "I leveled up"

## Repository Security

### Secrets
- **NO** secrets, API keys, tokens, passwords, or credentials in the repository
- Use `.env` files (gitignored) for local development
- Use GitHub Actions secrets for CI/CD
- The `.gitignore` excludes: `.env`, `.env.*`, `*.pem`, `*.key`, `*.keystore`

### Scanning
- Review all diffs before committing
- Search for accidental secret inclusion: passwords, tokens, keys
- CI should include a basic secret scan step

## Input Validation (Future Phases)

### Network Input
- Validate all RPC parameters server-side
- Check types, ranges, and business rules
- Reject and log impossible inputs
- Disconnect clients that consistently send invalid data

### Rate Limiting
- Limit RPC calls per client per second
- Limit chat messages per client per minute
- Limit inventory operations per client per second
- Log rate-limit violations for analysis

## Anti-Cheat Strategy

**Primary defense: server authority.** If the server calculates all outcomes, most cheats are ineffective.

| Cheat Type          | Defense                                          |
|---------------------|--------------------------------------------------|
| Speed hack          | Server validates movement speed                  |
| Teleport            | Server validates position delta per tick          |
| Damage hack         | Server calculates all damage                     |
| Item duplication    | Server is authoritative over inventory           |
| Wall hack           | Area of Interest limits data sent to client      |
| Auto-aim / bot      | Behavioral analysis (future, Phase 9)            |

**No client-side anti-cheat.** Client-side detection is always bypassable on a modified client. Server authority is the primary and most reliable defense.

## Authentication (Future — Phase 5)

- Secure password hashing (bcrypt/argon2)
- HTTPS for all client-server communication
- Token-based sessions (JWT or similar)
- Session expiration and refresh
- Account lockout after repeated failed attempts

## Economy Security (Future — Phase 7)

- All currency transactions validated server-side
- Transaction logging for audit
- Rollback capability for exploited transactions
- Rate limiting on trades and purchases
- Anomaly detection for unusual economic activity

## Dependency Security

- Minimize external dependencies
- Review licenses of all dependencies
- Keep Godot version updated for security patches
- Monitor for known vulnerabilities in dependencies

## Logging and Audit (Future)

- Log all significant game events server-side
- Log authentication attempts (success and failure)
- Log economic transactions
- Log admin actions
- Retain logs for incident investigation
- Never log passwords or tokens

## Incident Response (Future)

1. Detect: monitoring and player reports
2. Contain: ability to ban accounts, disable features
3. Investigate: logs, transaction history
4. Remediate: rollback exploited gains, patch vulnerability
5. Communicate: inform affected players

## Current Phase (Phase 0) Checklist

- [x] .gitignore excludes secrets and sensitive files
- [x] No secrets in repository
- [x] Security policy documented
- [ ] CI secret scan (to be configured when tests exist)
- [ ] Pre-commit hook for secret detection (recommended for Phase 1)
