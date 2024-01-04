import { icpfinally_backend, createActor } from "../../declarations/icpfinally_backend";
import moment from "moment";

function getDate(millseconds){
  return moment(new Date(Number(millseconds / BigInt(1000000)))).format('HH:mm:ss DD/MM/YYYY');
}
async function post(){
  let post_button = document.getElementById("post");
  post_button.disabled = true;
  let post_input = document.getElementById("post_input");
  let content = post_input.value.toString();
  await icpfinally_backend.post(content);
  post_button.disabled = false;
  load_posts();
}

async function load_posts(){
  let posts = await icpfinally_backend.posts(0);
  let postOl = document.getElementById("posts");
  postOl.innerHTML = "";
  for (var i=0; i< posts.length; i++){
    let n_li = document.createElement("li");
    // n_li.setAttribute("class", "post_l");
    let post = posts[i];
    let l_p = document.createElement("span");
    let p_c = document.createElement("span");
    p_c.innerText = post.content;
    let p_t = document.createElement("span");
    p_t.innerText = getDate(post.ctime);
    p_t.setAttribute("style", "float: right;");
    l_p.appendChild(p_c);
    l_p.appendChild(p_t);
    n_li.appendChild(l_p);
    postOl.appendChild(n_li);
  }
}

async function load_followers(){
  let follows = await icpfinally_backend.follows();
  let followsUl = document.getElementById("follows");
  for (var i=0;i<follows.length; i++){
    let follow = follows[i];
    let n_li = document.createElement("li");
    let n_a = document.createElement("a");
    n_a.innerText = follow.name;
    n_a.href = "#";
    n_a.onclick = () => follower_posts(follow.id, follow.name);
    n_li.appendChild(n_a);
    followsUl.appendChild(n_li);
  }
}

async function follower_posts(canisterId, authorName){
  let authNameEle = document.getElementById("followname");
  authNameEle.innerText = authorName;
  let actor = createActor(canisterId);
  let posts = await actor.posts(0);
  let followPostsOl = document.getElementById("followPosts")
  followPostsOl.innerHTML = "";
  for (var i=0; i< posts.length; i++){
    let post = posts[i];
    let n_li = document.createElement("li");
    let p_c = document.createElement("span");
    p_c.innerText = post.content;
    let p_t = document.createElement("span");
    p_t.innerText = getDate(post.ctime);
    p_t.setAttribute("style", "float: right;");
    n_li.append(p_c);
    n_li.append(p_t);
    followPostsOl.appendChild(n_li);
  }
}

async function onload(){
  let post_button = document.getElementById("post");
  post_button.onclick = post;
  load_posts();
  load_followers();
}

window.onload = onload;