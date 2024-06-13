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
      h: raycast("raycast/window-management/left-half"),
      j: raycast("raycast/window-management/maximize"),
      k: raycast("raycast/window-management/center"),
      l: raycast("raycast/window-management/right-half"),
      u: raycast("raycast/window-management/previous-desktop"),
      i: raycast("raycast/window-management/next-desktop"),
      g: raycast("raycast/window-management/next-display"),
      n: key_code("tab", ["right_control", "right_shift"]),
      m: key_code("tab", ["right_control"]),
      o: key_code("mission_control"),
    },

    // Open
    o: {
      a: app("Arc"),
      c: app("Fantastical"),
      e: app("Mail"),
      h: app("Home"),
      n: app("Obsidian"),
      p: app("Spotify"),
      s: app("Slack"),
      t: app("Todoist"),
      x: app("Kitty"),
      b: app("Google Chrome"),
      r: app("Tuple"),
      w: app("Linear"),

      j: key_code("tab", ["right_command", "right_shift"]),
      k: key_code("tab", ["right_command"]),
    },

    // Find
    f: {
      o: raycast(
        "extensions/KevinBatdorf/obsidian/searchNoteCommand?arguments=%7B%22searchArgument%22%3A%22%22%2C%22tagArgument%22%3A%22%22%7D"
      ),
    },

    // Email
    e: {
      i: key_code("delete_or_backspace"), // delete
      j: key_code("down_arrow"),
      k: key_code("up_arrow"),
      r: key_code("n", ["right_shift", "right_command"]),
      u: key_code("a", ["control", "right_command"]), // archive
    },

    // System
    s: {
      b: raycast("VladCuciureanu/toothpick/manage-bluetooth-connections"),
      e: key_code("spacebar", ["right_control", "right_command"]),
      j: key_code("volume_decrement"),
      k: key_code("volume_increment"),
      l: raycast("lucaschultz/input-switcher/toggle"),
      m: raycast("raycast/navigation/search-menu-items"),
      o: key_code("q", ["right_control", "right_command"]),
      p: raycast("raycast/screenshots/paste-recent-screenshot"),
      t: raycast("raycast/system/toggle-system-appearance"),
      0: raycast("raycast/system/lock-screen"),
    },

    // Direction
    d: {
      h: key_code("left_arrow"),
      j: key_code("down_arrow"),
      k: key_code("up_arrow"),
      l: key_code("right_arrow"),

      u: key_code("page_down"),
      i: key_code("page_up"),

      // trigger homerow
      m: key_code("f12"),
    },

    // musiC
    c: {
      p: key_code("play_or_pause"),
      j: key_code("fastforward"),
      k: key_code("rewind"),
    },

    // Raycast
    r: {
      c: raycast("raycast/system/open-camera"),
      p: raycast("raycast/raycast/confetti"),
      a: raycast("raycast/raycast-ai/ai-chat"),
      h: raycast("raycast/clipboard-history/clipboard-history"),
    },

    // Notifications
    n: {
      g: raycast("raycast/github/notifications", { fg: true }),
      l: raycast("linear/linear/notifications", { fg: true }),
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
