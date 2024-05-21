import { createApp, createNativeView, registerElement } from "nativescript-vue";
import Home from "./components/Home.vue";
import DemoSwiftUISlot from "./components/DemoSwiftUISlot.vue";

import {
  registerSwiftUI,
  SwiftUI,
  SwiftUIManager,
  UIDataDriver,
} from "@nativescript/swift-ui";

registerElement("SwiftUI", () => SwiftUI);

// Registering SwiftUI Components
declare var DemoSwiftUIProvider: any;
registerSwiftUI(
  "demoSwiftUI",
  (view) => new UIDataDriver(DemoSwiftUIProvider.alloc().init(), view)
);

// Registering Components for use within SwiftUI
// Init the shared factory manually when not using SwiftUI app lifecycle boot setup
NativeScriptViewFactory.initShared();

const viewRefs = new Map<string, any>();
SwiftUIManager.registerNativeScriptViews(
  {
    DemoSwiftUISlot,
  },
  {
    create(id: string, component: any) {
      const view = createNativeView(component, {
        id,
      });

      viewRefs.set(id, view);
      view.mount();

      return view.nativeView;
    },
    destroy(id: string) {
      const view = viewRefs.get(id);
      if (view) {
        view.unmount();
        viewRefs.delete(id);
      }
    },
  }
);

createApp(Home).start();
