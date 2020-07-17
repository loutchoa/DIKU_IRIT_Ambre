var fs = require('fs');
var path2sfmFile = process.argv[2];

var data = JSON.parse(fs.readFileSync(path2sfmFile,'utf-8'));

var text = '';
var f = data.intrinsics[0].pxFocalLength;
var x0 = data.intrinsics[0].principalPoint[0];
var y0 = data.intrinsics[0].principalPoint[1];

text += 'K = [' + f +' 0 ' + x0 + ';\n 0 ' + f + ' ' + y0 + ';\n 0 0 1];\n\n'
for (var extIndex = 0; extIndex<data.poses.length; extIndex++) {
    var ext = data.poses[extIndex];
    text += 'R(:,:,' + (extIndex + 1) + ') = [';
    for (var rowIndex = 0; rowIndex < ext.pose.transform.rotation.length; rowIndex++) {
        var row = ext.pose.transform.rotation[rowIndex];
        if ((rowIndex + 1) % 3 != 0) {
            text += row + ' ';
        } else if((rowIndex + 1) == 9) {
            text += row + '];\n\n';
        } else {
            text += row + ';\n';
        }
    }
    text += 'C(:,' + (extIndex + 1) + ') = [';
    text += ext.pose.transform.center.join(';') + '];\n\n';
}

console.log(text);
