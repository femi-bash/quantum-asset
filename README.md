# Quantum Asset Orchestrator

[![Clarity](https://img.shields.io/badge/Clarity-Smart%20Contract-blue)](https://clarity-lang.org/)
[![Stacks](https://img.shields.io/badge/Stacks-Blockchain-orange)](https://stacks.co/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Overview

The **Quantum Asset Orchestrator** is a revolutionary multi-asset allocation engine built on the Stacks blockchain using Clarity smart contracts. This institutional-grade protocol provides sophisticated asset allocation strategies with autonomous rebalancing mechanisms, enabling users to create customizable investment vehicles with precision-engineered risk management.

## Features

### 🎯 Core Functionality

- **Multi-Asset Portfolio Management**: Support for up to 10 different tokens per portfolio
- **Dynamic Asset Allocation**: Customize allocation percentages with basis point precision
- **Automated Rebalancing**: Intelligent rebalancing recommendations and execution
- **User Portfolio Tracking**: Comprehensive portfolio ownership and management system

### 🛡️ Security & Validation

- **Authorization Controls**: Owner-only access to portfolio modifications
- **Input Validation**: Comprehensive validation for percentages, token IDs, and portfolio parameters
- **Error Handling**: Detailed error constants for precise debugging and user feedback
- **Safe Math Operations**: Built-in protection against overflow and underflow

### 📊 Advanced Features

- **Portfolio Analytics**: Calculate rebalancing requirements and portfolio health
- **Flexible Asset Management**: Add, remove, and modify asset allocations
- **Protocol Administration**: Secure ownership transfer and protocol governance

## Technical Specifications

### Contract Architecture

```clarity
;; Core Data Structures
- Portfolios: Portfolio metadata and configuration
- PortfolioAssets: Individual asset allocation and composition
- UserPortfolios: User-portfolio relationship mapping
```

### Key Constants

- `MAX-TOKENS-PER-PORTFOLIO`: 10 tokens maximum per portfolio
- `BASIS-POINTS`: 10,000 (for percentage calculations)
- `PROTOCOL-FEE`: 25 basis points (0.25%)

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| 100 | `ERR-NOT-AUTHORIZED` | Unauthorized access attempt |
| 101 | `ERR-INVALID-PORTFOLIO` | Portfolio does not exist or is inactive |
| 102 | `ERR-INSUFFICIENT-BALANCE` | Insufficient token balance |
| 103 | `ERR-INVALID-TOKEN` | Invalid or unsupported token |
| 104 | `ERR-REBALANCE-FAILED` | Rebalancing operation failed |
| 105 | `ERR-PORTFOLIO-EXISTS` | Portfolio already exists |
| 106 | `ERR-INVALID-PERCENTAGE` | Invalid percentage value |
| 107 | `ERR-MAX-TOKENS-EXCEEDED` | Too many tokens for single portfolio |
| 108 | `ERR-LENGTH-MISMATCH` | Mismatched array lengths |
| 109 | `ERR-USER-STORAGE-FAILED` | Failed to update user storage |
| 110 | `ERR-INVALID-TOKEN-ID` | Invalid token identifier |

## Usage Guide

### Creating a Portfolio

```clarity
;; Create a new portfolio with two assets
(contract-call? .quantum-asset create-portfolio
  (list 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.wrapped-bitcoin
        'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R.wrapped-ethereum)
  (list u6000 u4000)) ;; 60% BTC, 40% ETH
```

### Rebalancing a Portfolio

```clarity
;; Execute portfolio rebalancing
(contract-call? .quantum-asset rebalance-portfolio u1)
```

### Updating Asset Allocation

```clarity
;; Update allocation for token 0 to 70%
(contract-call? .quantum-asset update-portfolio-allocation u1 u0 u7000)
```

### Reading Portfolio Data

```clarity
;; Get portfolio information
(contract-call? .quantum-asset get-portfolio u1)

;; Get user's portfolios
(contract-call? .quantum-asset get-user-portfolios 'SP1H1733V5MZ3SZ9XRW9FKYGEZT0JDGEB8Y634C7R)

;; Calculate rebalancing requirements
(contract-call? .quantum-asset calculate-rebalance-amounts u1)
```

## API Reference

### Public Functions

#### `create-portfolio`

Creates a new portfolio with specified assets and allocations.

**Parameters:**

- `initial-tokens`: List of up to 10 token contract addresses
- `percentages`: List of allocation percentages (in basis points)

**Returns:** Portfolio ID on success

#### `rebalance-portfolio`

Executes rebalancing operations for a portfolio.

**Parameters:**

- `portfolio-id`: Unique portfolio identifier

**Returns:** Boolean success indicator

#### `update-portfolio-allocation`

Modifies asset allocation percentages within an existing portfolio.

**Parameters:**

- `portfolio-id`: Portfolio identifier
- `token-id`: Asset index within portfolio
- `new-percentage`: New allocation percentage (in basis points)

**Returns:** Boolean success indicator

### Read-Only Functions

#### `get-portfolio`

Retrieves complete portfolio information.

#### `get-portfolio-asset`

Fetches specific asset details within a portfolio.

#### `get-user-portfolios`

Returns all portfolios owned by a specific user.

#### `calculate-rebalance-amounts`

Calculates rebalancing requirements and recommendations.

## Development

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development environment
- [Node.js](https://nodejs.org/) - For testing framework
- [TypeScript](https://www.typescriptlang.org/) - For type-safe tests

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd quantum-asset

# Install dependencies
npm install

# Run contract checks
clarinet check

# Execute tests
npm test
```

### Testing

The project includes comprehensive test coverage using Vitest and Clarinet:

```bash
# Run all tests
npm test

# Run specific test file
npm test -- tests/quantum-asset.test.ts

# Run tests in watch mode
npm run test:watch
```

### Contract Validation

```bash
# Check contract syntax and semantics
clarinet check

# Deploy to local testnet
clarinet integrate

# Console interaction
clarinet console
```

## Architecture Decisions

### Data Storage Strategy

- **Portfolios Map**: Stores core portfolio metadata for efficient lookups
- **PortfolioAssets Map**: Composite key structure for asset-specific data
- **UserPortfolios Map**: List-based storage for user portfolio relationships

### Validation Framework

- **Input Sanitization**: All public functions validate inputs before execution
- **Authorization Checks**: Owner-only modifications with tx-sender validation
- **Boundary Conditions**: Percentage limits and token count constraints

### Error Handling

- **Granular Error Codes**: Specific error constants for different failure modes
- **Fail-Fast Approach**: Early validation to prevent partial state changes
- **Descriptive Errors**: Clear error messages for debugging and user feedback

## Security Considerations

### Access Control

- Portfolio modifications restricted to original creators
- Protocol administration limited to designated owner
- Safe ownership transfer mechanisms

### Input Validation

- Percentage bounds checking (0-10000 basis points)
- Token count limits enforcement
- Array length validation for parameter consistency

### State Management

- Atomic operations to prevent partial updates
- Consistent state transitions across all functions
- Protected against common smart contract vulnerabilities

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Clarity best practices and conventions
- Maintain comprehensive test coverage
- Document all public functions and complex logic
- Use descriptive variable and function names

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Roadmap

### Phase 1: Core Infrastructure ✅

- Basic portfolio creation and management
- Asset allocation framework
- User portfolio tracking

### Phase 2: Advanced Features 🚧

- Automated rebalancing algorithms
- Risk assessment tools
- Performance analytics

### Phase 3: Integration & Scaling 📋

- DeFi protocol integrations
- Cross-chain asset support
- Institutional features

## Support

For questions, issues, or contributions:

- Create an issue in the GitHub repository
- Join our community discussions
- Review the documentation and examples
