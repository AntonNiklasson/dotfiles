import fs from "fs";
import { KarabinerRules, Manipulator } from "./types";
import { createLayers, app, raycast, key_code, open } from "./utils";

const hyperManipulator: Manipulator = {
  description: "CapsLock -> Hyper",
  from: {
    key_code: "caps_lock",
    modifiers: {
      optional: ["any"],
    },
  },
  to: [
    {
      set_variable: {
        name: "hyper",
        value: 1,
      },
    },
  ],
  to_after_key_up: [
    {
      set_variable: {
        name: "hyper",
        value: 0,
      },
    },
  ],
  to_if_alone: [
    {
      key_code: "escape",
    },
  ],
  type: "basic",
};

const rules: KarabinerRules[] = [
  {
    description: "Hyper (⌃⌥⇧⌘)",
    manipulators: [hyperManipulator],
  },
  ...createLayers({
    // Window
    w: {
      h: raycast("extensions/raycast/window-management/left-half"),
      j: raycast("extensions/raycast/window-management/maximize"),
      k: raycast("extensions/raycast/window-management/center"),
      l: raycast("extensions/raycast/window-management/right-half"),
      u: raycast("extensions/raycast/window-management/previous-desktop"),
      i: raycast("extensions/raycast/window-management/next-desktop"),
      n: raycast("extensions/raycast/window-management/next-display"),
    },

    // Open
    o: {
      a: app("Arc"),
      c: app("Calendar"),
      d: open("'obsidian://advanced-uri?vault=notes&daily=true'"),
      e: app("Mail"),
      h: app("Home"),
      n: app("Obsidian"),
      p: app("Spotify"),
      s: app("Slack"),
      t: app("Todoist"),
      x: app("iTerm"),
    },

    // Find
    f: {
      g: open("https://google.com"),
      o: raycast(
        "extensions/KevinBatdorf/obsidian/searchNoteCommand?arguments=%7B%22searchArgument%22%3A%22%22%2C%22tagArgument%22%3A%22%22%7D"
      ),
    },

    // Email specific
    e: {
      j: key_code("down_arrow"),
      k: key_code("up_arrow"),
      i: key_code("delete_or_backspace"), // delete
      u: key_code("a", ["control", "right_command"]), // archive
      r: key_code("n", ["right_shift", "right_command"]),
    },

    // System
    s: {
      k: key_code("volume_increment"),
      j: key_code("volume_decrement"),
      u: key_code("display_brightness_decrement"),
      i: key_code("display_brightness_increment"),
      l: key_code("q", ["right_control", "right_command"]),
      e: key_code("spacebar", ["right_control", "right_command"]),
      m: raycast("extensions/raycast/navigation/search-menu-items"),
      0: raycast("extensions/raycast/system/sleep"),
    },

    // Direction
    d: {
      h: key_code("left_arrow"),
      j: key_code("down_arrow"),
      k: key_code("up_arrow"),
      l: key_code("right_arrow"),
    },

    // musiC
    c: {
      p: key_code("play_or_pause"),
      j: key_code("fastforward"),
      k: key_code("rewind"),
    },

    // Raycast
    r: {
      c: raycast("extensions/raycast/system/open-camera"),
      n: raycast("script-commands/dismiss-notifications"),
      p: raycast("extensions/raycast/raycast/confetti"),
      a: raycast("extensions/raycast/raycast-ai/ai-chat"),
      h: raycast("extensions/raycast/clipboard-history/clipboard-history"),
      t: raycast("extensions/lucaschultz/input-switcher/toggle"),
    },
  }),
];

fs.writeFileSync(
  "karabiner.json",
  JSON.stringify(
    {
      global: {
        show_in_menu_bar: true,
      },
      profiles: [
        {
          name: "Default",
          complex_modifications: {
            rules,
          },
        },
      ],
    },
    null,
    2
  )
);
