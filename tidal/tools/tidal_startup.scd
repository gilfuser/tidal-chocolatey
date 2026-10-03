// BEGIN TidalCycles Chocolatey startup

s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
s.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
s.options.numWireBufs = 64 * 16; // increase this if you get "exceeded number of interconnect buffers" messages
s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"

if (ServerOptions.devices.indexOfEqual("ASIO : ASIO4ALL v2").notNil) {
    "Usando ASIO4ALL.".warn;
    s.options.device = "ASIO : ASIO4ALL v2";
} {
    "Nenhum driver ASIO esperado encontrado; usando dispositivo padrão.".warn;
};

s.waitForBoot {
    ~dirt.stop;
    ~dirt = SuperDirt(2, s);
    ~dirt.doNotReadYet = true;
    ~dirt.loadSoundFiles;
    ~dirt.start(57120, 0!8);
};

// END TidalCycles Chocolatey startup
