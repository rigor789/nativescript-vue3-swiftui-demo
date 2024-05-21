//
//  DemoSwiftUI.swift
//

import SwiftUI

func createProjector(value: CGFloat, inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat, clamp: Bool) -> CGFloat {
    let inNormal = inMax - inMin
    if (inNormal == 0) {
      // avoid divide by 0
      return outMin;
    }
    let projected = (value - inMin) / (inMax - inMin) * (outMax - outMin) + outMin
    if (clamp) {
        return min(max(projected, outMin), outMax)
    }
    return projected
}

class ObservablePoint: ObservableObject {
    @Published var x = 0.0
    @Published var y = 0.0
}

class DemoSwiftUIData: ObservableObject {
    @Published var maxValue: Double = 25.0
    @Published var direction: String = "right"
    @Published var sensitivityMultiplier: Double = 0.25

    // Data callback
    var valueChanged: ((Double, Bool) -> Void)?
}

struct DemoSwiftUI: View {
    @ObservedObject var data: DemoSwiftUIData

    @State private var isDragging = false
    @State private var value = 0.0;
    @ObservedObject private var coordinates: ObservablePoint = ObservablePoint();

    init(data: DemoSwiftUIData) {
        self.data = data
    }

    var body: some View {
        let saturationOffset = CGSize(
            width: data.direction == "left" || data.direction == "right" ? coordinates.x : 0,
            height: data.direction  == "up" || data.direction == "down" ? coordinates.y : 0
        )

        ZStack {
            NativeScriptView(id: "DemoSwiftUISlot")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .opacity(1.0)
        .offset(isDragging ? saturationOffset : CGSizeZero)
        .gesture(
            DragGesture(minimumDistance: 0)
               .onChanged({ gesture in
                    if(!isDragging) {
                        isDragging = true;
                    }


                    let dragLength = 50.0;
                    let dragY = data.sensitivityMultiplier * gesture.translation.height;
                    let dragX = data.sensitivityMultiplier * gesture.translation.width;

                    print("dragY: \(dragY)");

                    value = createProjector(
                        value: data.direction == "up" || data.direction == "down" ? dragY : dragX,
                        inMin: 0,
                        inMax: data.direction == "up" || data.direction == "left" ?  -dragLength  : dragLength,
                        outMin: 0,
                        outMax: data.maxValue,
                        clamp: true
                    )

                    // Emit value change.
                    data.valueChanged?(value, true);

                    coordinates.y = createProjector(
                        value: dragY,
                        inMin:  data.direction == "up" ? -dragLength : 0,
                        inMax:  data.direction == "up" ?  0  : dragLength,
                        outMin: data.direction == "up" ? -dragLength : 0,
                        outMax: data.direction == "up" ?  0  : dragLength,
                        clamp: true
                    );

                    coordinates.x = createProjector(
                        value: dragX,
                        inMin:  data.direction == "left" ? -dragLength : 0,
                        inMax:  data.direction == "left" ?  0  : dragLength,
                        outMin: data.direction == "left" ? -dragLength : 0,
                        outMax: data.direction == "left" ?  0  : dragLength,
                        clamp: true
                    );
               })
               .onEnded({ gesture in
                    data.valueChanged?(0, false);

                    if #available(iOS 17.0, *) {
                        withAnimation(.interactiveSpring()) {
                            isDragging = false
                        } completion: {
                            value = 0
                        }
                    } else {
                        isDragging = false
                        value = 0
                    }
               })
       )
    }
}

@objc
class DemoSwiftUIProvider: UIViewController, SwiftUIProvider {
    private var swiftUIData = DemoSwiftUIData()
    private var swiftUI: DemoSwiftUI?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        swiftUIData.valueChanged = { value, isDragging in
            self.onEvent!([
                "valueChanged": value,
                "isDragging": isDragging
            ])
        }
    }


    /// Receive data from NativeScript
    func updateData(data: NSDictionary) {
        let enumerator = data.keyEnumerator()
        while let k = enumerator.nextObject() {
            let key = k as! String
            let value = data.object(forKey: key)
            // if any data needed, setup switch cases here...
            switch(key) {
                case "maxValue":
                    swiftUIData.maxValue = value as! Double
                case "direction":
                    swiftUIData.direction = value as! String
                case "sensitivityMultiplier":
                    swiftUIData.sensitivityMultiplier = value as! Double
                default:
                    break
            }
        }

        if (self.swiftUI == nil) {
            swiftUI = DemoSwiftUI(data: swiftUIData)
            setupSwiftUIView(content: swiftUI)
        } else {
            // engage data binding right away
            self.swiftUI?.data = swiftUIData
        }
    }

    /// Allow sending of data to NativeScript
    var onEvent: ((NSDictionary) -> ())?
}

