;; Treatment Outcome Tracking Contract

;; Data Maps
(define-map treatments
  { treatment-id: (string-ascii 36) }
  {
    patient-id: (string-ascii 36),
    provider-id: (string-ascii 36),
    procedure-code: (string-ascii 10),
    diagnosis-code: (string-ascii 10),
    start-date: uint,
    end-date: uint,
    outcome-score: (optional int)
  }
)

(define-map aggregated-outcomes
  { procedure-code: (string-ascii 10), diagnosis-code: (string-ascii 10) }
  {
    total-treatments: uint,
    total-score: int,
    last-updated: uint
  }
)

;; Public Functions
(define-public (record-treatment
  (treatment-id (string-ascii 36))
  (patient-id (string-ascii 36))
  (provider-id (string-ascii 36))
  (procedure-code (string-ascii 10))
  (diagnosis-code (string-ascii 10))
  (start-date uint)
)
  (let ((existing-treatment (map-get? treatments { treatment-id: treatment-id })))
    (if (is-some existing-treatment)
      (err u1) ;; Treatment already recorded
      (begin
        (map-set treatments
          { treatment-id: treatment-id }
          {
            patient-id: patient-id,
            provider-id: provider-id,
            procedure-code: procedure-code,
            diagnosis-code: diagnosis-code,
            start-date: start-date,
            end-date: u0,
            outcome-score: none
          }
        )
        (ok true)
      )
    )
  )
)

(define-public (update-treatment-outcome
  (treatment-id (string-ascii 36))
  (end-date uint)
  (outcome-score int)
)
  (let ((treatment (map-get? treatments { treatment-id: treatment-id })))
    (if (is-none treatment)
      (err u2) ;; Treatment not found
      (let ((updated-treatment (merge (unwrap-panic treatment)
        {
          end-date: end-date,
          outcome-score: (some outcome-score)
        }
      )))
        (map-set treatments { treatment-id: treatment-id } updated-treatment)
        (update-aggregated-outcomes
          (get procedure-code updated-treatment)
          (get diagnosis-code updated-treatment)
          outcome-score
        )
        (ok true)
      )
    )
  )
)

(define-read-only (get-treatment (treatment-id (string-ascii 36)))
  (map-get? treatments { treatment-id: treatment-id })
)

(define-read-only (get-aggregated-outcome (procedure-code (string-ascii 10)) (diagnosis-code (string-ascii 10)))
  (map-get? aggregated-outcomes { procedure-code: procedure-code, diagnosis-code: diagnosis-code })
)

;; Private Functions
(define-private (update-aggregated-outcomes (procedure-code (string-ascii 10)) (diagnosis-code (string-ascii 10)) (new-score int))
  (let (
    (current-aggregation (default-to
      { total-treatments: u0, total-score: 0, last-updated: u0 }
      (map-get? aggregated-outcomes { procedure-code: procedure-code, diagnosis-code: diagnosis-code })
    ))
  )
    (map-set aggregated-outcomes
      { procedure-code: procedure-code, diagnosis-code: diagnosis-code }
      {
        total-treatments: (+ (get total-treatments current-aggregation) u1),
        total-score: (+ (get total-score current-aggregation) new-score),
        last-updated: block-height
      }
    )
  )
)

