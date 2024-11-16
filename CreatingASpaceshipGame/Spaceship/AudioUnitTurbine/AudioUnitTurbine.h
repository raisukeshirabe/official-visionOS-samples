/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Header file for dynamic turbine audio.
*/

//
//  AudioUnitTurbine.h
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>


const OSType kAudioUnitSubtype_Turbine = 'Trbn';

NS_ASSUME_NONNULL_BEGIN

const extern AudioComponentDescription AudioUnitTurbineComponentDescription;

@interface AudioUnitTurbine : AUAudioUnit

+ (void)instantiate:(void(^ _Nonnull)(AudioUnitTurbine * _Nullable audioUnit, NSError * _Nullable error))completion;

@property (nonatomic, assign) float throttle;
@property (nonatomic, assign) float carrierFrequencyMin;
@property (nonatomic, assign) float carrierFrequencyBandwidth;

@end

NS_ASSUME_NONNULL_END
