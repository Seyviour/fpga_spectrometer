from random import sample
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb.binary import BinaryValue
from cocotb.handle import SimHandleBase
from cocotb.queue import Queue
from cocotb.types import LogicArray



"""
module idx2RAM #(
    parameter
    ADDRESS_WIDTH = 12,
    NO_FFTS = 50,
    FFT_SIZE = 256,
    NO_BANKS = 2
) (
    input wire clk,
    input wire signed [FFT_IDX_WIDTH-1: 0] FFT_IDX,
    input wire [SAMPLE_IDX_WIDTH-1:0] sample_idx,

    output reg [1: 0] bank_select, 
    output reg [ADDRESS_WIDTH-1: 0] wr_address
);
"""

@cocotb.test()
async def test_idx2RAM(dut: SimHandleBase):

    thisClk = Clock(dut.clk, 10, "ns")
    dut.FFT_IDX.value = 0
    cocotb.start_soon(thisClk.start())

    check = False
    for fft_idx in range (50): 
        for sample_idx in range(128):
            await FallingEdge(dut.clk)
            # fft_idx = fft_idx % 32
            sample_idx = sample_idx % 128

            dut.FFT_IDX.value = fft_idx
            dut.sample_idx.value =  sample_idx

            await RisingEdge(dut.clk)
            await Timer(1, "ns")
            wr_address = LogicArray(dut.wr_address.value).integer
            assert wr_address == (fft_idx%32) * 128 + sample_idx, \
                f"fft_idx:{fft_idx}  sample_idx:{sample_idx}     wr_address:{wr_address}"

            if (fft_idx < 32):
                assert dut.bank_select.value.integer == 1
            else:
                assert dut.bank_select.value.integer == 2
            

