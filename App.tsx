import { StatusBar } from 'expo-status-bar';
import { StyleSheet, Text, View } from 'react-native';
import {Redirect} from "expo-router";

import React, { Component } from 'react';
// import {
//   ViroScene,
//   ViroText,
//   Viro360Image,
//   ViroARSceneNavigator,
// } from '@viro-community/react-viro';

var styles = StyleSheet.create({
  helloWorldTextStyle: {
    fontFamily: 'Arial',
    fontSize: 60,
    color: '#ffffff',
    textAlignVertical: 'center',
    textAlign: 'center',  
  },
  container: {
    flex: 1,
    backgroundColor: '#fff',
    alignItems: 'center',
    justifyContent: 'center',
  },
});

export default function App() {
  return <></>
}

// const myScene = () => (
//   <ViroScene>
//     <Viro360Image source={require('./assets/amongus.png')} />
//     <ViroText text="Hello World!" position={[0, 0, -2]} style={styles.helloWorldTextStyle} />
//   </ViroScene>
// );