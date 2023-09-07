const form = document.getElementById('form');
const table = document.getElementById('result-table')
const error_div = document.getElementById('error_div');

// function showError(msg, delay){
//     error_div.innerText = msg;

//     setTimeout(function() {
//         error_div.innerText = "";

//     }, delay);
// }

let x_values = [];

document.querySelectorAll(".x_val").forEach(function(button){
    button.addEventListener("click",handler);
})

function handler(event ){
    x_values.push(event.target.value);
}

form.addEventListener('submit', function(event ){
    event.preventDefault();

    const formData = new FormData(form);
    const x = x_values[x_values.length - 1];
    const y = formData.get('y_field');
    const R = formData.get('R_value');

    formData.append('x_field', x);

    console.log(x, y, R);
    

    if(-4 <= x && x <= 4 && -3 <= y && y <= 5 && 1 <= R && R <= 5){
        fetch('php/script.php', {
            method: 'POST',
            body: formData
        })
        .then(response => response.json()) //promise 
        .then(data => {
                const curTime = new Date().toLocaleString("en-US", {timeZone: "Europe/Moscow"});
                const content = `<tr>
                                    <td>${x}</td>
                                    <td>${y}</td>
                                    <td>${R}</td>
                                    <td>${data.collision}</td>
                                    <td>${data.exectime}</td>
                                    <td>${curTime}</td>
                                 </tr>`

                table.innerHTML += content;           
        })
    } else {
        // showError("Недопустимые значения", 3000)
        alert("HUI");
    }
})