module twiddleROM #(
    parameter
    N = 32,
    word_size = 16,
    memory_file_real = "/home/saviour/study/fft_hdl/data/out.real"
) (
    input wire clk,
    input wire [$clog2(N)-1: 0] read_address,
    output wire [word_size*2-1: 0] twiddle
    // output reg [word_size-1: 0] twiddle_im
);


//CALLING THEM TWIDDLE FACTORS IS NOT ACCURATE
//I JUST COULDN'T THINK OF A BETTER NAME


reg [word_size-1:0] twiddleROM [N-1:0];

//reg [$clog2(N)-1: 0] reg_read_address; 

initial begin
    $readmemh(memory_file_real, twiddleROM);
end

// initial begin
//     $dumpfile("twiddleROM.vcd");
//     $dumpvars(0, twiddleROM);
// end


    //reg_read_address <= read_address; 
assign twiddle = {twiddleROM[read_address]};


// assign twiddle = {twiddle_real_ROM[read_address] ,twiddle_im_ROM[read_address]};


endmodule


