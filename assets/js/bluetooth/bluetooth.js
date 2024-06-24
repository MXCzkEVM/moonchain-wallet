class BluetoothRemoteGATTCharacteristic extends EventTarget {
  constructor(service, uuid, value) {
    super();
    this.service = service;
    this.uuid = uuid;
    this.value = value;
    // this.properties = properties;
  }

  async startNotifications() {
    const data = { 'this': this.uuid, 'serviceUUID': this.service.uuid, }

    await window.axs.callHandler('BluetoothRemoteGATTCharacteristic.startNotifications', data);
    return this;
  }

  async getCharacteristics(characteristic) {}

  async getIncludedService(service) {}

  async getIncludedServices(service) {}

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
    let data = { 'this': this.uuid, 'characteristic': characteristic }
    console.log("Service changed: ",  JSON.stringify(data));
    const resp = await window.axs?.callHandler(
      "BluetoothRemoteGATTService.getCharacteristic",
      data
    );        
    console.log("Service changed:4 ",  resp);
    const characteristicInstance = new BluetoothRemoteGATTCharacteristic(this, resp.uuid, resp.value)
    navigator.bluetooth.characteristicArray.push(characteristicInstance);
    // resp.startNotifications = eval(resp.startNotifications);
    return characteristicInstance;
  }

  async getCharacteristics(characteristic) {}

  async getIncludedService(service) {}

  async getIncludedServices(service) {}

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
    const self = this;
    this.bluetoothRemoteGATTServer = {
      connect: async () => {
        const resp = await window.axs?.callHandler(
          "BluetoothRemoteGATTServer.connect",
          {}
        );
        resp.getPrimaryService = eval(resp.getPrimaryService);
        return resp;
      },

      getPrimaryService: async (data) => {
        const resp = await window.axs?.callHandler(
          "BluetoothRemoteGATTServer.getPrimaryService",
          data
        );
        const  service = new BluetoothRemoteGATTService(resp.device, resp.uuid, resp.isPrimary);
        self.serviceArray.push(service);
        // resp.getCharacteristic = eval(resp.getCharacteristic);
        return service;
      },
    };

    // this.bluetoothRemoteGATTService = {
    //   getCharacteristic: async (data) => {
    //     console.log("Service changed: ",  JSON.stringify(data));
    //     var resp = await window.axs?.callHandler(
    //       "BluetoothRemoteGATTService.getCharacteristic",
    //       data
    //     );        
    //     console.log("Service changed:3 ",  resp);
    //     this.characteristicArray.push(resp);
    //     // resp.startNotifications = eval(resp.startNotifications);
    //     return resp;
    //   },
    // };

    // this.bluetoothRemoteGATTCharacteristic = {
    //   startNotifications: async (data) => {
    //     var resp = await window.axs?.callHandler(
    //       "BluetoothRemoteGATTService.startNotifications",
    //       data
    //     );
    //     console.log("Service changed:3 ",  resp);
    //     resp.startNotifications = eval(resp.startNotifications);
    //     return resp;
    //   }
    // }
  }

  async requestDevice(options) {
    const resp = await window.axs?.callHandler("requestDevice", options);
    

    resp.gatt.connect = eval(resp.gatt.connect);
    return resp;
  }

  dispatchCharacteristicEvent(characteristicUUID, eventName) {
      let selectedCharacteristic = this.getCharacteristicByUUID(characteristicUUID);
      console.log('X');
      if (selectedCharacteristic != undefined) {
        console.log('X1');
        selectedCharacteristic.dispatchEvent(new Event(eventName),);
        console.log('X2');
      }
  }

  updateCharacteristicValue(characteristicUUID, base64String) {
    const binaryString = atob(base64String);
    const len = binaryString.length;
    const bytes = new Uint8Array(len);
    for (let i = 0; i < len; i++) {
      bytes[i] = binaryString.charCodeAt(i);
    }
    const dv = new DataView(bytes.buffer, bytes.byteOffset, bytes.byteLength);
    let selectedCharacteristic = this.getCharacteristicByUUID(characteristicUUID);
    selectedCharacteristic.value = dv;
    this.dispatchCharacteristicEvent(characteristicUUID, 'characteristicvaluechanged')
  }

  getServiceByUUID(serviceUUID) {
    return this.serviceArray.find(service => service.uuid === serviceUUID);
  }

  getCharacteristicByUUID(characteristicUUID) {
    return this.characteristicArray.find(characteristic => characteristic.uuid === characteristicUUID);
  }
}

navigator.bluetooth = new AXSBluetooth();
console.log("hallo");
console.log(JSON.stringify(navigator.bluetooth , null, 2));


// Simulated classes for completeness
// class BluetoothRemoteGATTCharacteristic {
//   constructor(uuid) {
//     this.uuid = uuid;
//   }
// }

// var serviceCopy;

// Usage example
// const device = { name: "Device1" };
// const service = new BluetoothRemoteGATTService(device, "1234", true);
// console.log(JSON.stringify(service));

// service.addEventListener("serviceadded", (ev) => {
//   console.log("Service added:", ev);
//   console.log("data:", ev.detail);
//   ev.detail.dispatchEvent(new Event("servicechanged"));
// });

// service.addEventListener("servicechanged", (ev) => {
//   console.log("Service changed:", ev);
// });

// service.addEventListener("serviceremoved", (ev) => {
//   console.log("Service removed:", ev);
// });

// {"device":{"name":"Device1"},"uuid":"1234","isPrimary":true}

// {device: {name: "Device1"}, uuid: 1234, isPrimary: true}
// Dispatching events for testing
// service.dispatchEvent(new Event("serviceadded"));
// service.dispatchEvent(new Event("servicechanged"));
// service.dispatchEvent(new Event("serviceremoved"));

// hello() {
//   const customEvent = new CustomEvent("serviceadded", { detail: this });
//   this.dispatchEvent(customEvent);
// }

// async helloToFlutter() {
//   serviceCopy = this;
//   await window.axs?.callHandler("helloToFlutter", serviceCopy);
//   this.addEventListener("serviceadded", (ev) => {
//     console.log("Here is the ");
//     console.log("Service added:", ev);
//     console.log("data:", ev.detail);
//     ev.detail.dispatchEvent(new Event("servicechanged"));
//   });
// }
