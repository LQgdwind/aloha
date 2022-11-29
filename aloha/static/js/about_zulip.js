import ClipboardJS from "clipboard";
import $ from "jquery";

import render_about_aloha from "../templates/about_aloha.hbs";

import * as browser_history from "./browser_history";
import * as overlays from "./overlays";
import {page_params} from "./page_params";

export function launch() {
    overlays.open_overlay({
        name: "about-aloha",
        $overlay: $("#about-aloha"),
        on_close() {
            browser_history.exit_overlay();
        },
    });

    new ClipboardJS("#about-aloha .fa-copy");
}

export function initialize() {
    const rendered_about_aloha = render_about_aloha({
        aloha_version: page_params.aloha_version,
        aloha_merge_base: page_params.aloha_merge_base,
        is_fork:
            page_params.aloha_merge_base &&
            page_params.aloha_merge_base !== page_params.aloha_version,
    });
    $(".app").append(rendered_about_aloha);
}
