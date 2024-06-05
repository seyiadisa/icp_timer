import Timer "mo:base/Timer";
import Nat "mo:base/Nat";
import List "mo:base/List";

actor TimerCreator {
  type Times = {
    #_30secs;
    #_1min;
    #_5mins;
  };

  type TimerType = {
    id : Nat;
    done : Bool;
  };

  var timeList = List.nil<TimerType>();

  public func setATimer(time : Times) : async Nat {
    var timerId : Nat = 0;
    switch (time) {
      case (#_30secs) {
        timerId := Timer.setTimer<system>(
          #seconds 30,
          func() : async () {
            markDone(timerId);
          },
        );

        timeList := List.push<TimerType>({ id = timerId; done = false }, timeList);
      };
      case (#_1min) {
        timerId := Timer.setTimer<system>(
          #seconds 60,
          func() : async () {
            markDone(timerId);
          },
        );

        timeList := List.push<TimerType>({ id = timerId; done = false }, timeList);
      };
      case (#_5mins) {
        timerId := Timer.setTimer<system>(
          #seconds 300,
          func() : async () {
            markDone(timerId);
          },
        );

        timeList := List.push<TimerType>({ id = timerId; done = false }, timeList);
      };
    };

    return timerId;
  };

  private func markDone(id : Nat) {
    removeTimer(id);
    timeList := List.push<TimerType>({ id = id; done = true }, timeList);
  };

  private func removeTimer(id : Nat) {
    func removeThisTimer(timer : TimerType) : Bool {
      timer.id != id;
    };

    timeList := List.filter(timeList, removeThisTimer);
  };

  public func cancelATimer(id : Nat) : async Text {
    Timer.cancelTimer(id);
    removeTimer(id);

    return "Timer with id " # Nat.toText(id) # "cancelled";
  };

  public func checkTimer(id : Nat) : async Text {
    let matchedTimer = List.find<TimerType>(
      timeList,
      func timer {
        timer.id == id;
      },
    );

    switch (matchedTimer) {
      case (null) { return "Could not find a timer with id " # Nat.toText(id) };
      case (?matchedTimer) {
        if (matchedTimer.done == true) {
          return "This timer is done";
        } else {
          return "This timer is still running";
        };
      };
    };
  };
};
