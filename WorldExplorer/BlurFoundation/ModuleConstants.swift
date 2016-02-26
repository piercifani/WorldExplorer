//
//  Created by Pierluigi Cifani on 26/02/16.
//  Copyright © 2016 BlurSoftware. All rights reserved.
//

import Foundation

let ModuleName = "com.blursoftware"

func submoduleName(submodule : String) -> String {
    return ModuleName + "." + submodule
}

func queueForSubmodule(submodule : String) -> dispatch_queue_t {
    return dispatch_queue_create(submoduleName(submodule), nil)
}
