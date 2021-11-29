//
//  RemoteEventLoaderTests.swift
//  letsPlayTests
//
//  Created by Sebastian Leon on 29.11.2021.
//

import XCTest
import letsPlay
import Combine

class RemoteEventLoaderTests: XCTestCase {

    var cancellable: Set<AnyCancellable>!

    override func setUp() {
        cancellable = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellable = nil
    }

    func test_doesNotCallLoadUponCreation() {

        let sut = RemoteEventLoaderSpy()

        XCTAssertEqual(sut.loadCounter, 0)
    }

    func test_load_returnEventsOnSuccessfulResult() {

        let sut = RemoteEventLoaderSpy()
        let expectedEvents = [anyEvent(), anyEvent()]

        sut.load()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure:
                        XCTFail("Expected success, got: error")
                    default: break
                    }
                },
                receiveValue: { receivedEvents in
                    XCTAssertEqual(receivedEvents, expectedEvents)
                }
            )
            .store(in: &cancellable)

        sut.completeWith(events: expectedEvents)
    }

    func test_load_completesWithErrorUponClientFailure() {

        let sut = RemoteEventLoaderSpy()
        let expectedError = anyNSError()

        sut.load()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case let .failure(receivedError):
                        XCTAssertEqual(receivedError as NSError?, expectedError as NSError?)
                    default: break
                    }
                },
                receiveValue: { receivedEvents in
                    XCTFail("Expected Failure, got: \(receivedEvents)")
                }
            )
            .store(in: &cancellable)

        sut.completeWith(error: expectedError)
    }

    private func anyEvent() -> Event {
        Event(id: UUID(), name: "any name", startDate: Date(), endDate: Date())
    }

    private func anyNSError() -> Error {
        NSError(domain: "any error", code: 1)
    }

    private class RemoteEventLoaderSpy {

        var request = [PassthroughSubject<[Event], Error>]()

        var loadCounter: Int {
            request.count
        }

        func load() -> AnyPublisher<[Event], Error> {

            let publisher = PassthroughSubject<[Event], Error>()
            request.append(publisher)
            return publisher
                .eraseToAnyPublisher()
        }

        func completeWith(events: [Event], at index: Int = 0) {
            request[index].send(events)
            request[index].send(completion: .finished)
        }

        func completeWith(error: Error, at index: Int = 0) {
            request[index].send(completion: .failure(error))
        }
    }
}
