import { StoryVotes } from "./StoryVotes.elm";
import { FlagPopup } from "./FlagPopup.elm";
import facebookInjector from "./injectors/facebook";
import twitterInjector from "./injectors/twitter";
import {
  extensionPopupInjector,
  isExtensionPopup
} from "./injectors/extensionPopup";
import uuidv4 from "uuid/v4";

const uuid = localStorage.getItem("uuid") || uuidv4();
localStorage.setItem("uuid", uuid);

const popup = FlagPopup.fullscreen({ uuid, isExtensionPopup });

let storyVotes = {};
const onInject = ({ elem, url, title }) => {
  if (elem.querySelector(".fake-news-detector")) return false;

  const newNode = document.createElement("div");
  newNode.className = "fake-news-detector";
  newNode.style.position = "relative";
  elem.insertBefore(newNode, elem.firstChild);

  const storyVoting = StoryVotes.embed(newNode, {
    url,
    title,
    isExtensionPopup
  });
  storyVoting.ports.openFlagPopup.subscribe(popup.ports.openFlagPopup.send);
  storyVotes[url] = storyVoting;
};

popup.ports.broadcastVote.subscribe(({ url, categoryId }) => {
  storyVotes[url].ports.addVote.send({ categoryId });
});

facebookInjector(onInject);
twitterInjector(onInject);
extensionPopupInjector(onInject);
