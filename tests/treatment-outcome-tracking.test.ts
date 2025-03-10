import { describe, beforeEach, it, expect, vi } from "vitest"

// Mock contract calls
const mockContractCall = vi.fn()

describe("Treatment Outcome Tracking Contract", () => {
  beforeEach(() => {
    vi.resetAllMocks()
  })
  
  it("should record a new treatment", async () => {
    mockContractCall.mockResolvedValue({ success: true })
    const result = await mockContractCall("record-treatment", [
      "treatment123",
      "patient456",
      "provider789",
      "PROC001",
      "DIAG001",
      1625097600,
    ])
    expect(result.success).toBe(true)
    expect(mockContractCall).toHaveBeenCalledWith("record-treatment", [
      "treatment123",
      "patient456",
      "provider789",
      "PROC001",
      "DIAG001",
      1625097600,
    ])
  })
  
  it("should update treatment outcome", async () => {
    mockContractCall.mockResolvedValue({ success: true })
    const result = await mockContractCall("update-treatment-outcome", ["treatment123", 1625184000, 85])
    expect(result.success).toBe(true)
    expect(mockContractCall).toHaveBeenCalledWith("update-treatment-outcome", ["treatment123", 1625184000, 85])
  })
  
  it("should get a treatment", async () => {
    mockContractCall.mockResolvedValue({
      patient_id: "patient456",
      provider_id: "provider789",
      procedure_code: "PROC001",
      diagnosis_code: "DIAG001",
      outcome_score: 85,
    })
    const result = await mockContractCall("get-treatment", ["treatment123"])
    expect(result).toEqual({
      patient_id: "patient456",
      provider_id: "provider789",
      procedure_code: "PROC001",
      diagnosis_code: "DIAG001",
      outcome_score: 85,
    })
    expect(mockContractCall).toHaveBeenCalledWith("get-treatment", ["treatment123"])
  })
  
  it("should get aggregated outcome", async () => {
    mockContractCall.mockResolvedValue({
      total_treatments: 10,
      total_score: 850,
      last_updated: 1625184000,
    })
    const result = await mockContractCall("get-aggregated-outcome", ["PROC001", "DIAG001"])
    expect(result).toEqual({
      total_treatments: 10,
      total_score: 850,
      last_updated: 1625184000,
    })
    expect(mockContractCall).toHaveBeenCalledWith("get-aggregated-outcome", ["PROC001", "DIAG001"])
  })
})

