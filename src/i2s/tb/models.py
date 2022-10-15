import cocotb
from cocotb.types import Range, LogicArray, Logic
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from random import randint
from cocotb.clock import Clock
import logging


class i2sDriver:
    def __init__(self, clk, left_list=None, right_list=None, num_words=20):
        self.clk = clk
        self._coro = None
        self.range = (-2**(23), 2**(23)-1)
        self.num_words = num_words if left_list is None else len(left_list)
        logging.basicConfig(filename='model.log', encoding='utf-8', level=logging.DEBUG)
        logging.debug("initializing")


        #list of signed 24 bit integers
        self.left_list = left_list
        self.left_list_gen = (LogicArray(x, Range(23,0)) for x in  left_list) \
                            if left_list is not None \
                            else self.create_random_sequence(Range(23,0), num_words)

        self.right_list = right_list
        self.right_list_gen = (LogicArray(x, Range(23,0)) for x in right_list) \
                            if right_list is not None \
                            else self.create_random_sequence(Range(23,0), num_words)

        # print(self.left_list)
        # print(self.right_list)

        
        
        self.SD = Logic(0)
        self.WS = Logic(0)

    def create_random_int(self, size=None):
        range = Range((size, 0))
        if range is None:
            range = self.range
        return randint(*range)

    
    def create_random_int_sequence(self, irange=None, length=24):

        # def random_gen(range, length):
        #     for _ in range(length):
        #         yield self.create_random_word(range)
        return (self.create_random_word(irange) for _ in range(length))


    def create_random_sequence(self, irange: Range, length):
        return (self.create_random_word(irange) for _ in range(length))

    def create_random_word(self, irange: Range):
        word = LogicArray(0, irange)
        word = self.randomize_word(word)
        return word
    
    

    def randomize_word(self, word: LogicArray):
        left = word.left
        right = word.right
        step = -1 if left > right else 1
        for idx in range(left, right+1, step):
            word[idx] = Logic(randint(0,1))
        return word


    async def sendWord(self, word):
        logging.debug("sending word")
        for bit in word:
            await FallingEdge(self.clk)
            self.SD = bit

    async def i2sWordSend(self, i2s_word, channel=0):
        # print("here")
        await FallingEdge(self.clk)
        self.WS = channel
        # await self.sendWord(self.create_random_word(Range(0,0)))
        await self.sendWord(i2s_word)
        await self.sendWord(self.create_random_word(Range(6,0)))

        #CLK 1 -> SEND RANDOM BIT
                  #TOGGLE WS (L/R SWITCH)
        #CLK 2 - 25 -> SEND 24 BIT INTEGER
        #CLK 26 - 32 -> SEND RANDOM 7-BIT INTEGER


    async def _run(self):
        # for idx in range(self.num_words):
        
            # try:
        while True:
            try:
                next_left = next(self.left_list_gen)
                print(next_left)
                await self.i2sWordSend(next_left, 0)
                next_right = next(self.right_list_gen)
                await self.i2sWordSend(next_right, 1)

            except:

                print("ALL DONE")
                break
        

        


    def start(self):
        if self._coro is not None:
            raise RuntimeError("Already Started")
        self._coro = cocotb.start_soon(self._run())



if __name__ == "__main__":

    
    clk = None
    aclk = Clock(clk, 10, units="ns")
    
    left_list = list(range(20))
    i2sTransmitter = i2sDriver(None, left_list)
    # cocotb.start_soon(aclk.start())

    @cocotb.test()
    def test(model):
        cocotb.start_soon(Clock(i2sTransmitter.clk, 10, units="ns").start())
        model.start()

    test(i2sTransmitter)

    
