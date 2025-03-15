package flixel.addons.effects;

import openfl.geom.Matrix;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.util.FlxDestroyUtil;

/**
 * @author Zaphod
 * NOTE: edited by richTrash21
 */
class FlxSkewedSprite extends FlxSprite
{
	/**
	 * Internal helper matrix object. Used for rendering calculations when matrixExposed is set to false
	 * NOTE: made static for perfomance reasons.
	 */
	@:noCompletion
	static var _skewMatrix:Matrix = new Matrix();

	public var skew(default, null):FlxPoint = FlxPoint.get();

	/**
	 * Tranformation matrix for this sprite.
	 * Used only when matrixExposed is set to true
	 */
	public var transformMatrix(default, null):Matrix = new Matrix();

	/**
	 * Bool flag showing whether transformMatrix is used for rendering or not.
	 * False by default, which means that transformMatrix isn't used for rendering
	 */
	public var matrixExposed:Bool = false;

	/**
	 * **WARNING:** A destroyed `FlxBasic` can't be used anymore.
	 * It may even cause crashes if it is still part of a group or state.
	 * You may want to use `kill()` instead if you want to disable the object temporarily only and `revive()` it later.
	 *
	 * This function is usually not called manually (Flixel calls it automatically during state switches for all `add()`ed objects).
	 *
	 * Override this function to `null` out variables manually or call `destroy()` on class members if necessary.
	 * Don't forget to call `super.destroy()`!
	 */
	override public function destroy():Void
	{
		skew = FlxDestroyUtil.put(skew);
		transformMatrix = null;

		super.destroy();
	}

	@:noCompletion
	override function drawComplex(camera:FlxCamera):Void
	{
		_frame.prepareMatrix(_matrix, FlxFrameAngle.ANGLE_0, checkFlipX(), checkFlipY());
		_matrix.translate(-origin.x, -origin.y);
		_matrix.scale(scale.x, scale.y);

		if (matrixExposed)
		{
			_matrix.concat(transformMatrix);
		}
		else
		{
			if (bakedRotationAngle <= 0)
			{
				updateTrig();

				if (angle != 0)
					_matrix.rotateWithTrig(_cosAngle, _sinAngle);
			}

			updateSkewMatrix();
			_matrix.concat(_skewMatrix);
		}

		getScreenPosition(_point, camera).subtractPoint(offset);
		_point.add(origin.x, origin.y);
		_matrix.translate(_point.x, _point.y);

		if (isPixelPerfectRender(camera))
		{
			_matrix.tx = Math.floor(_matrix.tx);
			_matrix.ty = Math.floor(_matrix.ty);
		}

		camera.drawPixels(_frame, framePixels, _matrix, colorTransform, blend, antialiasing, shader);
	}

	@:noCompletion
	function updateSkewMatrix():Void
	{
		_skewMatrix.identity();

		if (skew.x != 0 || skew.y != 0)
		{
			_skewMatrix.b = Math.tan(skew.y * FlxAngle.TO_RAD);
			_skewMatrix.c = Math.tan(skew.x * FlxAngle.TO_RAD);
		}
	}

	/**
	 * Determines the function used for rendering in blitting:
	 * `copyPixels()` for simple sprites, `draw()` for complex ones.
	 * Sprites are considered simple when they have an `angle` of `0`, a `scale` of `1`,
	 * don't use `blend` and `pixelPerfectRender` is `true`.
	 *
	 * @param   camera   If a camera is passed its `pixelPerfectRender` flag is taken into account
	 */
	override public function isSimpleRenderBlit(?camera:FlxCamera):Bool
	{
		return super.isSimpleRenderBlit(camera) && (skew.x == 0) && (skew.y == 0) && !matrixExposed;
	}
}
