## The Warp Field and You

The world you can see with normal vision is a straightforward Euclidian grid. All angles are right angles, and all distances match up nicely - travel ten meters north, ten meters east, ten meters south, and then ten meters west and you will always wind up exactly where you started. Gravity is always downward, and of uniform strength.

On a deeper layer, however, there is a warped grid to reality where distance no longer quite so consistent and "down" varies both in location and magnitude. A Warpfield Trigger is an arcane tool that can be used to measure this field, giving the strength and direction of the bias it imposes on reality. And, with the application of a little energy, a Warpfield Trigger can briefly loosen the operator's hold on the normal world and allow them to "fall" along the warp field's bent lines.

While wielding a Warpfield Trigger a HUD will be shown with an X, Y and Z displacement value. When "used" the Trigger will cause its holder to teleport in that given direction. Note that there is no guarantee that the destination location will be on solid ground - or in open air, for that matter. Be prepared either to deal with a fall or to dig your way out of entombment.

Using a Warpfield Trigger to travel like this is stressful on the mechanism and it will eventually break. It also can't be done too frequently, even with multiple different trigger devices - travel through warp leaves you momentarily in an unstable state that can't easily be forced back into the warpfield for a few seconds.

## Game considerations

The number of uses and the length of the cooldown are server-configurable variables, as is the strength of the noise fields used to provide displacement values in the various directions. By default the y axis doesn't displace as strongly as the X and Z axes (on average), but server administrators can play with these values to make warp field travel more or less powerful (and dangerous).

Warp field travel is not a highly practical thing but creative players will find uses for it. It can serve as an emergency escape route, provided the local warp field is strong enough to move you far. With a higher magnitude of y axis noise strength it could give access to cloudlands or otherwise inaccessible cavern layers beneath impenetrable layers of rock. A player may use it to enter and exit from an otherwise-sealed fortress hidden deep underground or to get through some other barrier - provided they can find just the right location to "jump" from.

If trigger wear is low (or disabled) and cooldown is short (or disabled) then you may find that repeated warp field jumps will eventually cause you to settle into specific locations where the strength of the field is nearly zero in all directions. These warp field "minima" are sargassos of a sort, the bottom of a hole into which all manner of dimensional detritus may settle. In a game where warp field travel is common these might serve as useful landmarks or gathering spots.

## API

``warpfield.get_warp_at(pos)`` will return the value of the warp field's displacement vector at any given point. You could perhaps use this to cause certain types of monsters to appear in warp field minima, or even allow them to teleport themselves when injured or threatened.

There's no way to "backtrace" from a location except via a brute force search. It's possible that more than one place will have a warp field displacement that leads to a particular destination pos.