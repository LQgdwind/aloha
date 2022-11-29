/* eslint-env commonjs */

"use strict";

module.exports = {
    files: [
        "./*.svg", // For web-only icons.
        "../../shared/icons/*.svg", // For icons to be shared with the mobile app.
    ],
    fontName: "aloha-icons",
    classPrefix: "aloha-icon-",
    baseSelector: ".aloha-icon",
    cssTemplate: "./template.hbs",
    ligature: false,
};
