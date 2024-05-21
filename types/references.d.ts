/// <reference path="../node_modules/@nativescript/types/index.d.ts" />

// Provided by @nativescript/core since 8.7
declare class NativeScriptViewFactory extends NSObject {
  static shared: NativeScriptViewFactory;
  static initShared();
  views: NSMutableDictionary<string, any>;
  viewCreator: (id: string) => void;
  viewDestroyer: (id: string) => void;
}
