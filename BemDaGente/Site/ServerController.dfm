object IWServerController: TIWServerController
  OldCreateOrder = False
  AppName = 'MyApp'
  Description = 'My IntraWeb Application'
  DisplayName = 'IntraWeb Application'
  Port = 8888
  Version = '15.1.5'
  SessionOptions.SessionTimeout = 100
  SessionOptions.RestartExpiredSession = True
  OnNewSession = IWServerControllerBaseNewSession
  Height = 310
  Width = 342
end
