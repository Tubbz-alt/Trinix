﻿module TaskManager.Mutex;

import Library;
import TaskManager;


public class Mutex {
	private SpinLock _spinLock;
	private LinkedList!Thread _waiting;
	private Thread _owner;

	public this() {
		_spinLock = new SpinLock();
		_waiting = new LinkedList!Thread();
	}

	~this() {
		delete _spinLock;
		delete _waiting;
	}

	public bool WaitOne() {
		_spinLock.WaitOne();

		if (_owner) {
			_waiting.Add(Task.CurrentThread);
			Task.CurrentThread.Sleep(ThreadStatus.MutexSleep, cast(void *)this, 0, _spinLock);
		} else {
			_owner = Task.CurrentThread;
			_spinLock.Release();
		}

		return true;
	}

	public void Release() {
		_spinLock.WaitOne();

		if (_waiting.Count) {
			_owner = _waiting.First.Value;
			_waiting.RemoveFirst();

			if (_owner.Status != ThreadStatus.Active)
				_owner.AddActive();
		} else
			_owner = null;

		_spinLock.Release();
	}

	public bool IsLocked() {
		return _owner !is null;
	}
}