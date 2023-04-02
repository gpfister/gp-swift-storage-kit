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

import SwiftUI

struct GPComplexCounterView: View {
    @StateObject private var counter = GPCounterViewModel()

    @State private var counterValue: Int32 = 0

    var body: some View {
        VStack {
            Text("\(counterValue)")
            HStack {
                Button("Add") {
                    counter.increase()
                }
                if let counter = counter.counter, counter > 0 {
                    Button("Remove") {
                        self.counter.decrease()
                    }
                }
            }
        }
        .onReceive(counter.$counter) { counterValue in
            self.counterValue = counterValue ?? 0
        }
    }
}

struct ComplexCounterView_Previews: PreviewProvider {
    static var previews: some View {
        GPComplexCounterView()
    }
}
