class BluetoothCharacteristicProperties {
  constructor(
    broadcast,
    read,
    writeWithoutResponse,
    write,
    notify,
    indicate,
    authenticatedSignedWrites,
    reliableWrite,
    writableAuxiliaries
  ) {
    this.broadcast = broadcast;
    this.read = read;
    this.writeWithoutResponse = writeWithoutResponse;
    this.write = write;
    this.notify = notify;
    this.indicate = indicate;
    this.authenticatedSignedWrites = authenticatedSignedWrites;
    this.reliableWrite = reliableWrite;
    this.writableAuxiliaries = writableAuxiliaries;
  }
}

class BluetoothDevice extends EventTarget {
  constructor(id, name, gatt, watchingAdvertisements) {
    super();
    this.id = id;
    this.name = name;
    this.gatt = gatt;
    this.watchingAdvertisements = watchingAdvertisements;
  }

  async watchAdvertisements() {
    console.log("BluetoothRemoteGATTServer:watchAdvertisements ");
    const response = await window.axs.callHandler(
      "BluetoothDevice.watchAdvertisements"
    );
    console.log(
      "BluetoothRemoteGATTServer:watchAdvertisements ",
      JSON.stringify(response, null, 2)
    );
    return response;
  }

  async forget() {
    console.log("BluetoothRemoteGATTServer:forget ");
    const response = await window.axs.callHandler("BluetoothDevice.forget");
    console.log(
      "BluetoothRemoteGATTServer:forget ",
      JSON.stringify(response, null, 2)
    );
    return response;
  }
}

class BluetoothRemoteGATTServer extends EventTarget {
  constructor(device, connected) {
    super();
    this.device = device;
    this.connected = connected;
  }

  async connect() {
    console.log("BluetoothRemoteGATTServer:connect ");
    const response = await window.axs?.callHandler(
      "BluetoothRemoteGATTServer.connect",
      {}
    );
    console.log(
      "BluetoothRemoteGATTServer:connect ",
      JSON.stringify(response, null, 2)
    );
    this.device = response.device;
    this.connected = response.connected;
    return this;
  }

  async disconnect() {
    console.log("BluetoothRemoteGATTServer:disconnect ");
    await window.axs.callHandler("BluetoothRemoteGATTServer.disconnect", {});
  }

  async getPrimaryService(service) {
    console.log("BluetoothRemoteGATTServer:getPrimaryService ", service);
    const data = { service: service };
    const response = await window.axs?.callHandler(
      "BluetoothRemoteGATTServer.getPrimaryService",
      data
    );
    const respService = new BluetoothRemoteGATTService(
      response.device,
      response.uuid,
      response.isPrimary
    );
    navigator.bluetooth.serviceArray.push(respService);
    console.log(
      "BluetoothRemoteGATTServer:getPrimaryService ",
      JSON.stringify(response, null, 2)
    );
    return respService;
  }

  async getPrimaryServices(service) {
    console.log("BluetoothRemoteGATTServer:getPrimaryServices ", service);
    const data = { service: service };
    const response = await window.axs.callHandler(
      "BluetoothRemoteGATTServer.getPrimaryServices",
      data
    );
    return response;
  }
}

class BluetoothRemoteGATTCharacteristic extends EventTarget {
  constructor(service, uuid, value, properties) {
    super();
    this.service = service;
    this.uuid = uuid;
    this.value = value;
    this.properties = properties;
  }

  async getDescriptor(descriptor) {
    console.log("BluetoothRemoteGATTCharacteristic:getDescriptor ", descriptor);
    const data = {
      this: this.uuid,
      serviceUUID: this.service.uuid,
      descriptor: descriptor,
    };
    const response = await window.axs.callHandler(
      "BluetoothRemoteGATTCharacteristic.getDescriptor",
      data
    );
    return response;
  }

  async getDescriptors(descriptor) {
    console.log(
      "BluetoothRemoteGATTCharacteristic:getDescriptors ",
      descriptor
    );
    const data = {
      this: this.uuid,
      serviceUUID: this.service.uuid,
      descriptor: descriptor,
    };

    const response = await window.axs.callHandler(
      "BluetoothRemoteGATTCharacteristic.getDescriptors",
      data
    );
    return response;
  }

  async readValue() {
    console.log("BluetoothRemoteGATTCharacteristic:readValue");
    const data = { this: this.uuid, serviceUUID: this.service.uuid };
    const response = await window.axs.callHandler(
      "BluetoothRemoteGATTCharacteristic.readValue",
      data
    );

    console.log(
      "BluetoothRemoteGATTCharacteristic:readValue",
      JSON.stringify(response, null, 2)
    );

    const bytes = new Uint8Array(response);
    console.log("Bytes : ", bytes);
    const dv = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    selectedCharacteristic.value = dv;

    return dv;
  }

  async writeValue(value) {
    console.log("BluetoothRemoteGATTCharacteristic:writeValue", value);
    const data = {
      this: this.uuid,
      serviceUUID: this.service.uuid,
      value: value,
    };

    const response = await window.axs.callHandler(
      "BluetoothRemoteGATTCharacteristic.writeValue",
      data
    );

    console.log(
      "BluetoothRemoteGATTCharacteristic:writeValue",
      JSON.stringify(response, null, 2)
    );

    if (response.error !== undefined && response.error === true) {
      throw new Error("Error while writing value.");
    }
  }

  async writeValueWithResponse(value) {
    console.log(
      "BluetoothRemoteGATTCharacteristic:writeValueWithResponse",
      value
    );
    const data = {
      this: this.uuid,
      serviceUUID: this.service.uuid,
      value: value,
    };

    await window.axs.callHandler(
      "BluetoothRemoteGATTCharacteristic.writeValueWithResponse",
      data
    );
  }

  async writeValueWithoutResponse(value) {
    console.log(
      "BluetoothRemoteGATTCharacteristic:writeValueWithoutResponse",
      value
    );
    const data = {
      this: this.uuid,
      serviceUUID: this.service.uuid,
      value: value,
    };

    await window.axs.callHandler(
      "BluetoothRemoteGATTCharacteristic.writeValueWithoutResponse",
      data
    );
  }

  async startNotifications() {
    console.log("BluetoothRemoteGATTCharacteristic:startNotifications");
    const data = { this: this.uuid, serviceUUID: this.service.uuid };

    await window.axs.callHandler(
      "BluetoothRemoteGATTCharacteristic.startNotifications",
      data
    );
    return this;
  }

  async stopNotifications() {
    console.log("BluetoothRemoteGATTCharacteristic:stopNotifications");
    const data = { this: this.uuid, serviceUUID: this.service.uuid };

    await window.axs.callHandler(
      "BluetoothRemoteGATTCharacteristic.stopNotifications",
      data
    );
    return this;
  }

  addEventListener(type, listener, useCapture = false) {
    // Custom addEventListener implementation to handle specific types
    super.addEventListener(type, listener, useCapture);
  }
}

class BluetoothRemoteGATTService extends EventTarget {
  constructor(device, uuid, isPrimary) {
    super();
    this.device = device;
    this.uuid = uuid;
    this.isPrimary = isPrimary;
  }

  async getCharacteristic(characteristic) {
    console.log(
      "BluetoothRemoteGATTService:getCharacteristic ",
      characteristic
    );
    let data = { this: this.uuid, characteristic: characteristic };
    const response = await window.axs?.callHandler(
      "BluetoothRemoteGATTService.getCharacteristic",
      data
    );
    console.log(
      "BluetoothRemoteGATTService:getCharacteristic ",
      JSON.stringify(response, null, 2)
    );
    const characteristicInstance = new BluetoothRemoteGATTCharacteristic(
      this,
      response.uuid,
      response.value,
      undefined
    );
    navigator.bluetooth.characteristicArray.push(characteristicInstance);
    return characteristicInstance;
  }

  async getCharacteristics(characteristic) {
    console.log(
      "BluetoothRemoteGATTService:getCharacteristics ",
      characteristic
    );
    const response = await window.axs.callHandler(
      "BluetoothRemoteGATTService.getCharacteristics",
      { this: "$uuid", characteristic: characteristic }
    );
    return response;
  }

  async getIncludedService(service) {
    console.log("BluetoothRemoteGATTService:getIncludedService ", service);
    const response = await window.axs.callHandler(
      "BluetoothRemoteGATTService.getIncludedService",
      { this: "$uuid", service: service }
    );
    return response;
  }

  async getIncludedServices(service) {
    console.log("BluetoothRemoteGATTService:getIncludedServices ", service);
    const response = await window.axs.callHandler(
      "BluetoothRemoteGATTService.getIncludedServices",
      { this: "$uuid", service: service }
    );
    return response;
  }

  addEventListener(type, listener, useCapture = false) {
    // Custom addEventListener implementation to handle specific types
    super.addEventListener(type, listener, useCapture);
  }
}

class AXSBluetooth {
  constructor() {
    this.serviceArray = [];
    this.characteristicArray = [];
    this.bluetoothDevice = {};
  }

  async requestDevice(options) {
    console.log("AXSBluetooth:requestDevice ", options);
    const response = await window.axs?.callHandler("requestDevice", options);

    const gatt = new BluetoothRemoteGATTServer(
      response.gatt.device,
      response.gatt.connected
    );

    const device = new BluetoothDevice(
      response.id,
      response.name,
      gatt,
      response.watchingAdvertisements
    );

    return device;
  }

  dispatchCharacteristicEvent(characteristicUUID, eventName) {
    console.log(
      "AXSBluetooth:dispatchCharacteristicEvent ",
      characteristicUUID,
      " ",
      eventName
    );
    let selectedCharacteristic =
      this.getCharacteristicByUUID(characteristicUUID);
    if (selectedCharacteristic != undefined) {
      selectedCharacteristic.dispatchEvent(new Event(eventName));
      console.log(
        "AXSBluetooth:dispatchCharacteristicEvent:eventName ",
        eventName
      );
    }
  }

  updateCharacteristicValue(characteristicUUID, value) {
    console.log(
      "AXSBluetooth:updateCharacteristicValue ",
      characteristicUUID,
      " ",
      eventName
    );
    const bytes = new Uint8Array(value);
    console.log("Bytes : ", bytes);
    console.log("Bytes type: ", typeof bytes);
    const dv = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    let selectedCharacteristic =
      this.getCharacteristicByUUID(characteristicUUID);

    selectedCharacteristic.value = dv;
    console.log(
      "Selected characteristic : ",
      JSON.stringify(selectedCharacteristic, null, 2)
    );
    this.dispatchCharacteristicEvent(
      characteristicUUID,
      "characteristicvaluechanged"
    );
  }

  getServiceByUUID(serviceUUID) {
    console.log("AXSBluetooth:getServiceByUUID ", serviceUUID);
    return this.serviceArray.find((service) => service.uuid === serviceUUID);
  }

  getCharacteristicByUUID(characteristicUUID) {
    console.log("AXSBluetooth:getCharacteristicByUUID ", characteristicUUID);
    return this.characteristicArray.find(
      (characteristic) => characteristic.uuid === characteristicUUID
    );
  }
}

navigator.bluetooth = new AXSBluetooth();
console.log(JSON.stringify(navigator.bluetooth, null, 2));
