type 
    Header* = object of RootObj

    TransportLayerProtocol* = object of RootObj

method to_buf*(packet: TransportLayerProtocol): ptr byte =
    # implemented by subclasses
    return nil