(
var finish, writeSuccessMarker;

writeSuccessMarker = {
    var markerPath = "SUPERDIRT_CHOCO_SUCCESS_MARKER".getenv;

    if (markerPath.notNil) {
        File.use(markerPath, "w", { |file|
            file.write("ok");
        });
    };
};

finish = {
    if (Quarks.isInstalled("SuperDirt")) {
        writeSuccessMarker.value;
        "SuperDirt 1.7.4 installed successfully.".postln;
        0.exit;
    } {
        "SuperDirt did not install correctly.".postln;
        1.exit;
    };
};

Quarks.checkForUpdates({
    if (Quarks.isInstalled("SuperDirt")) {
        "Removing existing SuperDirt before installing 1.7.4...".postln;
        Quarks.uninstall("SuperDirt");
    };

    Quarks.install("SuperDirt", "v1.7.4");
    finish.value;
});
)
