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
    const response = await window.axs.callHandler(
      "BluetoothDevice.watchAdvertisements"
    );
    return response;
  }

  async forget() {
    const response = await window.axs.callHandler("BluetoothDevice.forget");
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
    const resp = await window.axs?.callHandler(
      "BluetoothRemoteGATTServer.connect",
      {}
    );
    this.device = resp.device;
    this.connected = resp.connected;
    return this;
  }

  async disconnect() {
    await window.axs.callHandler("BluetoothRemoteGATTServer.disconnect", {});
  }

  async getPrimaryService(service) {
    const data = { service: service };
    const resp = await window.axs?.callHandler(
      "BluetoothRemoteGATTServer.getPrimaryService",
      data
    );
    const respService = new BluetoothRemoteGATTService(
      resp.device,
      resp.uuid,
      resp.isPrimary
    );
    navigator.bluetooth.serviceArray.push(respService);
    return respService;
  }

  async getPrimaryServices(service) {
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
    const data = { this: this.uuid, serviceUUID: this.service.uuid };
    const response = await window.axs.callHandler(
      "BluetoothRemoteGATTCharacteristic.readValue",
      data
    );
    return response;
  }

  async writeValue(value) {
    // We will need to change the value to Base64 for having a standard type to bridge data on that type.

    const data = {
      this: this.uuid,
      serviceUUID: this.service.uuid,
      value: value,
    };

    const resp = await window.axs.callHandler(
      "BluetoothRemoteGATTCharacteristic.writeValue",
      data
    );

    if (resp.error !== undefined && resp.error === true) {
      throw new Error("Error while writing value.");
    }
  }

  async writeValueWithResponse(value) {
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
    const data = { this: this.uuid, serviceUUID: this.service.uuid };

    await window.axs.callHandler(
      "BluetoothRemoteGATTCharacteristic.startNotifications",
      data
    );
    return this;
  }

  async stopNotifications() {
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
    let data = { this: this.uuid, characteristic: characteristic };
    const resp = await window.axs?.callHandler(
      "BluetoothRemoteGATTService.getCharacteristic",
      data
    );
    const characteristicInstance = new BluetoothRemoteGATTCharacteristic(
      this,
      resp.uuid,
      resp.value,
      undefined
    );
    navigator.bluetooth.characteristicArray.push(characteristicInstance);
    return characteristicInstance;
  }

  async getCharacteristics(characteristic) {
    const response = await window.axs.callHandler(
      "BluetoothRemoteGATTService.getCharacteristics",
      { this: "$uuid", characteristic: characteristic }
    );
    return response;
  }

  async getIncludedService(service) {
    const response = await window.axs.callHandler(
      "BluetoothRemoteGATTService.getIncludedService",
      { this: "$uuid", service: service }
    );
    return response;
  }

  async getIncludedServices(service) {
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
    const resp = await window.axs?.callHandler("requestDevice", options);

    const gatt = new BluetoothRemoteGATTServer(
      resp.gatt.device,
      resp.gatt.connected
    );

    const device = new BluetoothDevice(
      resp.id,
      resp.name,
      gatt,
      resp.watchingAdvertisements
    );

    return device;
  }

  dispatchCharacteristicEvent(characteristicUUID, eventName) {
    let selectedCharacteristic =
      this.getCharacteristicByUUID(characteristicUUID);
    console.log("X");
    if (selectedCharacteristic != undefined) {
      console.log("X1");
      selectedCharacteristic.dispatchEvent(new Event(eventName));
      console.log("X2");
    }
  }

  updateCharacteristicValue(characteristicUUID, base64String) {
    const bytes = new Uint8Array(base64String);
    console.log("Bytes : ", bytes);
    const dv = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    let selectedCharacteristic =
      this.getCharacteristicByUUID(characteristicUUID);

    console.log(
      "Selected characteristic : ",
      JSON.stringify(selectedCharacteristic, null, 2)
    );
    selectedCharacteristic.value = dv;
    this.dispatchCharacteristicEvent(
      characteristicUUID,
      "characteristicvaluechanged"
    );
  }

  getServiceByUUID(serviceUUID) {
    return this.serviceArray.find((service) => service.uuid === serviceUUID);
  }

  getCharacteristicByUUID(characteristicUUID) {
    return this.characteristicArray.find(
      (characteristic) => characteristic.uuid === characteristicUUID
    );
  }
}

navigator.bluetooth = new AXSBluetooth();
console.log(JSON.stringify(navigator.bluetooth, null, 2));
