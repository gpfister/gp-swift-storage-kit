//
// gp-swift-storage-kit-test
// Copyright (c) 2022-2023, Greg PFISTER. MIT License.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import GPStorageKit
import SwiftUI

struct GPSimpleCounterView: View {
    @GPUserDefault(\.counter) private var counter

    var body: some View {
        VStack {
            Text("\(counter ?? 0)")
            //            Text("\(counter)")
            HStack {
                Button("Add") {
                    if let counter {
                        self.counter = counter + 1
                    } else {
                        counter = 1
                    }
                    //                    counter += 1
                }
                if let counter, counter > 0 {
                    Button("Remove") {
                        self.counter = counter - 1
                        //                        counter -= 1
                    }
                }
            }
        }
    }
}

struct SimpleCounterView_Previews: PreviewProvider {
    static var previews: some View {
        GPSimpleCounterView()
    }
}
