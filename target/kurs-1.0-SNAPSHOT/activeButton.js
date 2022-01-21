function activeButton(id){
    document.getElementsByClassName('navbar')[0].children[id].style.backgroundColor ="#04AA6D";
    document.getElementsByClassName('navbar')[0].children[id].children[0].className = 'active';
}