import fs from "fs";
import { KarabinerRules, Manipulator } from "./types";
import { createLayers, app, dl, key_code, open } from "./utils";

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
    // window
    w: {
      h: dl(
        new URL("raycast://extensions/raycast/window-management/left-half")
      ),
      j: dl(new URL("raycast://extensions/raycast/window-management/maximize")),
      k: dl(new URL("raycast://extensions/raycast/window-management/center")),
      l: dl(
        new URL("raycast://extensions/raycast/window-management/right-half")
      ),
      u: dl(
        new URL(
          "raycast://extensions/raycast/window-management/previous-desktop"
        )
      ),
      i: dl(
        new URL("raycast://extensions/raycast/window-management/next-desktop")
      ),
      g: dl(
        new URL("raycast://extensions/raycast/window-management/next-display")
      ),
      n: key_code("tab", ["right_control", "right_shift"]),
      m: key_code("tab", ["right_control"]),
      o: key_code("mission_control"),

      s: dl(
        new URL(
          "raycast://customWindowManagementCommand?&name=Browser%20Screenshot"
        )
      ),
    },

    // Open
    o: {
      a: app("Arc"),
      c: app("Google Chrome"),
      f: app("Figma"),
      m: app("Spotify"),
      n: app("Obsidian"),
      p: app("Tuple"),
      s: app("Slack"),
      t: app("Todoist"),
      w: app("Linear"),
      x: app("Kitty"),
      r: app("Reader"),
    },

    // Find
    f: {
      o: dl(
        new URL(
          "raycast://extensions/KevinBatdorf/obsidian/searchNoteCommand?arguments=%7B%22searchArgument%22%3A%22%22%2C%22tagArgument%22%3A%22%22%7D"
        )
      ),
      d: dl(
        new URL(
          "raycast://extensions/michaelschultz/figma-files-raycast-extension/index"
        )
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
      b: dl(
        new URL(
          "raycast://VladCuciureanu/toothpick/manage-bluetooth-connections"
        )
      ),
      e: key_code("spacebar", ["right_control", "right_command"]),
      j: key_code("volume_decrement"),
      k: key_code("volume_increment"),
      l: dl(
        new URL(
          "raycast://extensions/lucaschultz/input-switcher/toggle?launchType=background"
        )
      ),
      m: dl(
        new URL("raycast://extensions/raycast/navigation/search-menu-items")
      ),
      o: key_code("q", ["right_control", "right_command"]),
      p: dl(
        new URL(
          "raycast://extensions/raycast/screenshots/paste-recent-screenshot"
        )
      ),
      t: dl(
        new URL("raycast://extensions/raycast/system/toggle-system-appearance")
      ),
      0: dl(new URL("raycast://extensions/raycast/system/lock-screen")),
    },

    // Direction
    d: {
      h: key_code("left_arrow"),
      j: key_code("down_arrow"),
      k: key_code("up_arrow"),
      l: key_code("right_arrow"),

      u: key_code("page_down"),
      i: key_code("page_up"),
    },

    // "Insert"
    i: {
      l: dl(new URL("raycast://extensions/linear/linear/create-issue"), true),
      t: dl(new URL("raycast://extensions/doist/todoist/create-task"), true),
    },

    // Raycast
    r: {
      c: dl(new URL("raycast://extensions/raycast/system/open-camera")),
      p: dl(new URL("raycast://extensions/raycast/raycast/confetti")),
      a: dl(new URL("raycast://extensions/raycast/raycast-ai/ai-chat")),
      h: dl(
        new URL(
          "raycast://extensions/raycast/clipboard-history/clipboard-history"
        )
      ),
      b: dl(new URL("raycast://ai-commands/git-branch-name-generator")),
      n: dl(
        new URL("raycast://extensions/raycast/raycast-notes/raycast-notes")
      ),
    },

    // Notifications
    n: {
      g: dl(new URL("raycast://extensions/raycast/github/notifications"), true),
      l: dl(new URL("raycast://extensions/linear/linear/notifications"), true),
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
