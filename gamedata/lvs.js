data = JSON.parse(contenidojson);
for (x = 0; x <= data.length - 1; x++) {
    splitted = data[x][0].split(':')
    if (splitted[0] == 'select') {
        if (splitted.reverse()[0] == 'yes') {
            document.getElementById('selectablediv' + x).click();
        }
    } else if (splitted[0] == 'choose') {
		elem = document.getElementById('selectbox' + x).value = 1
    } else {
        elem = document.getElementById('textbox' + x)
        
        if (elem != null) {
            elem.innerHTML = data[x][0].replaceAll('$', "'");
        }
    }
}