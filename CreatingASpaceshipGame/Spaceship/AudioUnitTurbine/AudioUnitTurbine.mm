/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Implementation for dynamic turbine audio.
*/

#import "AudioUnitTurbine.h"
#import <AVFoundation/AVFoundation.h>
#import <Accelerate/Accelerate.h>
#import <os/log.h>

#include <atomic>

const AudioComponentDescription AudioUnitTurbineComponentDescription =
{
    kAudioUnitType_Generator,
    kAudioUnitSubtype_Turbine,
    kAudioUnitManufacturer_Apple,
    kAudioComponentFlag_SandboxSafe,
    0
};

struct TurbineState {
    // Fixed at time of allocating render resources.
    float mSampleRate = 48000;

    // Settable with Objective-C properties while the audio unit is running.
    std::atomic<float> mThrottle = 0.0;
    std::atomic<float> mCarrierFrequencyMin = 580;
    std::atomic<float> mCarrierFrequencyBandwidth = 250;

    // Internal rendering state.
    double mCarrierPhase = 0.0;
    double mModulationPhase = 0.0;

    void renderInto(float *buffer, AUAudioFrameCount frameCount);
};


void TurbineState::renderInto(float *buffer, AUAudioFrameCount frameCount)
{
    float sampleRate = mSampleRate;
    float throttle = mThrottle;
    float amplitude = throttle * 0.75 + 0.02;

    double dt = (1.0 / sampleRate) * 2 * M_PI;

    float carrierFrequency = sqrt(throttle) * mCarrierFrequencyBandwidth + mCarrierFrequencyMin;
    float modulationFrequency = sqrt(throttle) * 40.0 + 0.25;

    double carrierPhase = mCarrierPhase;
    double modulationPhase = mModulationPhase;

    for (int sample = 0; sample < int(frameCount); sample += 1) {
        buffer[sample] = sin(carrierPhase) * sin(modulationPhase) * amplitude;
        carrierPhase += dt * carrierFrequency;
        modulationPhase += dt * modulationFrequency;
        if (carrierPhase >= 2 * M_PI) {
            carrierPhase -= 2 * M_PI;
        }
        if (modulationPhase >= 2 * M_PI) {
            modulationPhase -= 2 * M_PI;
        }
    }
    mCarrierPhase = carrierPhase;
    mModulationPhase = modulationPhase;
}


@implementation AudioUnitTurbine {
    AUAudioUnitBus *mOutputBus;
    AUAudioUnitBusArray *mOutputBusArray;
    TurbineState mState;
}

+ (void)registerAU {
    // Register this class for use with the component description.
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [AUAudioUnit registerSubclass:self
               asComponentDescription:AudioUnitTurbineComponentDescription
                                 name:@"Turbine"
                              version:1];
    });
}

+ (void)instantiate:(void (^ _Nonnull __strong)(AudioUnitTurbine * _Nullable __strong, NSError * _Nullable __strong))completion {

    [self registerAU];

    [AUAudioUnit instantiateWithComponentDescription:AudioUnitTurbineComponentDescription
                                             options:0
                                   completionHandler:^(AUAudioUnit * _Nullable audioUnit, NSError * _Nullable error) {
        completion((AudioUnitTurbine *)audioUnit, error);
    }];
}

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription
                                     options:(AudioComponentInstantiationOptions)options
                                       error:(NSError **)outError{

    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    if (self != nil) {
        AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:48e3 channels:1];
        mOutputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
        mOutputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self
                                                                 busType:AUAudioUnitBusTypeOutput
                                                                  busses:@[mOutputBus]];

        [self resetParams];
    }

    return self;
}

- (BOOL)allocateRenderResourcesAndReturnError:(NSError *__autoreleasing  _Nullable *)outError {
    os_log(OS_LOG_DEFAULT, "AudioUnitTurbine.allocateRenderResources self=%p", (__bridge void*)self);
    BOOL ok = [super allocateRenderResourcesAndReturnError:outError];
    if (ok) {
        [self resetParams];
    }
    return ok;
}

- (void)resetParams
{
    mState.mSampleRate = [mOutputBusArray objectAtIndexedSubscript:0].format.sampleRate;
}

- (AUInternalRenderBlock)internalRenderBlock {

    TurbineState *statePtr = &self->mState;

    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags *actionFlags,
                              const AudioTimeStamp       *timestamp,
                              AUAudioFrameCount           frameCount,
                              NSInteger                   outputBusNumber,
                              AudioBufferList            *outputData,
                              const AURenderEvent        *realtimeEventListHead,
                              AURenderPullInputBlock      pullInputBlock) {
        if (outputBusNumber != 0) {
            return kAudioUnitErr_InvalidParameter;
        }
        if (outputData == nil) {
            return kAudioUnitErr_InvalidParameter;
        }

        if (outputData->mNumberBuffers != 1 || outputData->mBuffers[0].mNumberChannels != 1) {
            return kAudioUnitErr_FormatNotSupported;
        }

        float *bufferPtr = static_cast<float *>(outputData->mBuffers[0].mData);
        statePtr->renderInto(bufferPtr, frameCount);

        return noErr;
    };
}

- (NSArray<NSNumber*>*)channelCapabilities {
    // Only supporting zero inputs and one output.
    return @[@0, @(1)];
}

- (AUAudioUnitBusArray *)outputBusses {
    return mOutputBusArray;
}

// MARK: - Properties

- (float)throttle {
    return mState.mThrottle;
}

- (void)setThrottle:(float)throttle {
    mState.mThrottle = throttle;
}

- (float)carrierFrequencyMin {
    return mState.mCarrierFrequencyMin;
}

- (void)setCarrierFrequencyMin:(float)carrierFrequencyMin {
    mState.mCarrierFrequencyMin = carrierFrequencyMin;
}

- (float)carrierFrequencyBandwidth {
    return mState.mCarrierFrequencyBandwidth;
}

- (void)setCarrierFrequencyBandwidth:(float)carrierFrequencyBandwidth {
    mState.mCarrierFrequencyBandwidth = carrierFrequencyBandwidth;
}

@end
