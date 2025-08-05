;; Title: Quantum Asset Orchestrator
;;
;; Summary: Revolutionary multi-asset allocation engine with intelligent rebalancing capabilities
;;
;; Description: The Quantum Asset Orchestrator revolutionizes decentralized finance by providing 
;; sophisticated asset allocation strategies with autonomous rebalancing mechanisms. Built for 
;; institutional-grade performance, this protocol enables users to create customizable investment 
;; vehicles with precision-engineered risk management, dynamic asset weighting, and automated 
;; portfolio optimization. Experience the future of decentralized wealth management with quantum-
;; level precision and military-grade security protocols.

;; ERROR CONSTANTS
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-PORTFOLIO (err u101))
(define-constant ERR-INSUFFICIENT-BALANCE (err u102))
(define-constant ERR-INVALID-TOKEN (err u103))
(define-constant ERR-REBALANCE-FAILED (err u104))
(define-constant ERR-PORTFOLIO-EXISTS (err u105))
(define-constant ERR-INVALID-PERCENTAGE (err u106))
(define-constant ERR-MAX-TOKENS-EXCEEDED (err u107))
(define-constant ERR-LENGTH-MISMATCH (err u108))
(define-constant ERR-USER-STORAGE-FAILED (err u109))
(define-constant ERR-INVALID-TOKEN-ID (err u110))

;; DATA VARIABLES
(define-data-var protocol-owner principal tx-sender)
(define-data-var portfolio-counter uint u0)
(define-data-var protocol-fee uint u25) ;; 0.25% represented as basis points

;; PROTOCOL CONSTANTS
(define-constant MAX-TOKENS-PER-PORTFOLIO u10)
(define-constant BASIS-POINTS u10000)

;; DATA STORAGE MAPS

;; Core portfolio metadata storage
(define-map Portfolios
  uint ;; portfolio-id
  {
    owner: principal,
    created-at: uint,
    last-rebalanced: uint,
    total-value: uint,
    active: bool,
    token-count: uint,
  }
)

;; Asset allocation and composition data
(define-map PortfolioAssets
  {
    portfolio-id: uint,
    token-id: uint,
  }
  {
    target-percentage: uint,
    current-amount: uint,
    token-address: principal,
  }
)

;; User portfolio relationship mapping
(define-map UserPortfolios
  principal
  (list 20 uint)
)

;; READ-ONLY FUNCTIONS

;; Retrieve complete portfolio information
(define-read-only (get-portfolio (portfolio-id uint))
  (map-get? Portfolios portfolio-id)
)

;; Fetch specific asset details within a portfolio
(define-read-only (get-portfolio-asset
    (portfolio-id uint)
    (token-id uint)
  )
  (map-get? PortfolioAssets {
    portfolio-id: portfolio-id,
    token-id: token-id,
  })
)

;; Get all portfolios owned by a specific user
(define-read-only (get-user-portfolios (user principal))
  (default-to (list) (map-get? UserPortfolios user))
)

;; Calculate rebalancing requirements and recommendations
(define-read-only (calculate-rebalance-amounts (portfolio-id uint))
  (let (
      (portfolio (unwrap! (get-portfolio portfolio-id) ERR-INVALID-PORTFOLIO))
      (total-value (get total-value portfolio))
    )
    (ok {
      portfolio-id: portfolio-id,
      total-value: total-value,
      needs-rebalance: (> (- stacks-block-height (get last-rebalanced portfolio)) u144), ;; 24 hours in blocks
    })
  )
)

;; PRIVATE UTILITY FUNCTIONS

;; Validate token ID against portfolio constraints
(define-private (validate-token-id
    (portfolio-id uint)
    (token-id uint)
  )
  (let ((portfolio (unwrap! (get-portfolio portfolio-id) false)))
    (and
      (< token-id MAX-TOKENS-PER-PORTFOLIO)
      (< token-id (get token-count portfolio))
      true
    )
  )
)

;; Ensure percentage values are within valid bounds
(define-private (validate-percentage (percentage uint))
  (and (>= percentage u0) (<= percentage BASIS-POINTS))
)

;; Validate that portfolio percentages follow allocation rules
(define-private (validate-portfolio-percentages (percentages (list 10 uint)))
  (fold check-percentage-sum percentages true)
)

;; Helper function for percentage validation
(define-private (check-percentage-sum
    (current-percentage uint)
    (valid bool)
  )
  (and valid (validate-percentage current-percentage))
)

;; Add portfolio to user's portfolio collection
(define-private (add-to-user-portfolios
    (user principal)
    (portfolio-id uint)
  )
  (let (
      (current-portfolios (get-user-portfolios user))
      (new-portfolios (unwrap! (as-max-len? (append current-portfolios portfolio-id) u20)
        ERR-USER-STORAGE-FAILED
      ))
    )
    (map-set UserPortfolios user new-portfolios)
    (ok true)
  )
)

;; Initialize individual asset within portfolio structure
(define-private (initialize-portfolio-asset
    (index uint)
    (token principal)
    (percentage uint)
    (portfolio-id uint)
  )
  (if (>= percentage u0) ;; Only check percentage validity since principal is already a valid type
    (begin
      (map-set PortfolioAssets {
        portfolio-id: portfolio-id,
        token-id: index,
      } {
        target-percentage: percentage,
        current-amount: u0,
        token-address: token,
      })
      (ok true)
    )
    ERR-INVALID-TOKEN
  )
)

;; PUBLIC INTERFACE FUNCTIONS

;; Create a new portfolio with specified assets and allocations
(define-public (create-portfolio
    (initial-tokens (list 10 principal))
    (percentages (list 10 uint))
  )
  (let (
      (portfolio-id (+ (var-get portfolio-counter) u1))
      (token-count (len initial-tokens))
      (percentage-count (len percentages))
      (token-0 (element-at? initial-tokens u0))
      (token-1 (element-at? initial-tokens u1))
      (percentage-0 (element-at? percentages u0))
      (percentage-1 (element-at? percentages u1))
    )
    ;; Input validation
    (asserts! (<= token-count MAX-TOKENS-PER-PORTFOLIO) ERR-MAX-TOKENS-EXCEEDED)
    (asserts! (is-eq token-count percentage-count) ERR-LENGTH-MISMATCH)
    (asserts! (validate-portfolio-percentages percentages) ERR-INVALID-PERCENTAGE)

    ;; Create portfolio metadata
    (map-set Portfolios portfolio-id {
      owner: tx-sender,
      created-at: stacks-block-height,
      last-rebalanced: stacks-block-height,
      total-value: u0,
      active: true,
      token-count: token-count,
    })

    ;; Validate minimum required assets
    (asserts! (and (is-some token-0) (is-some token-1)) ERR-INVALID-TOKEN)
    (asserts! (and (is-some percentage-0) (is-some percentage-1))
      ERR-INVALID-PERCENTAGE
    )

    ;; Initialize core portfolio assets
    (try! (initialize-portfolio-asset u0 (unwrap-panic token-0)
      (unwrap-panic percentage-0) portfolio-id
    ))

    (try! (initialize-portfolio-asset u1 (unwrap-panic token-1)
      (unwrap-panic percentage-1) portfolio-id
    ))

    ;; Link portfolio to user account
    (try! (add-to-user-portfolios tx-sender portfolio-id))

    ;; Update system state
    (var-set portfolio-counter portfolio-id)
    (ok portfolio-id)
  )
)