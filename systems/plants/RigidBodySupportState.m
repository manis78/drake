classdef RigidBodySupportState
  %RigidBodySupportState defines a set of supporting bodies and contacts for a rigid
  %  body manipulator

  properties (SetAccess=protected)
    bodies; % array of supporting body indices
    contact_pts; % cell array of supporting contact points, each cell is 3x[num pts per body]
    contact_groups; % cell array of cell arrays of contact group strings, 1 for each body
    num_contact_pts;  % convenience array containing the desired number of
                      %             contact points for each support body
    contact_surfaces; % int IDs either: 0 (terrain), -1 (any body in bullet collision world)
                      %             or (1:num_bodies) collision object ID
  end

  methods
    function obj = RigidBodySupportState(r,bodies,contact_groups,contact_surfaces)
      typecheck(r,'Biped');
      typecheck(bodies,'double');
      obj.bodies = bodies(bodies~=0);

      obj.num_contact_pts=zeros(length(obj.bodies),1);
      obj.contact_pts = cell(1,length(obj.bodies));
      obj.contact_groups = {};
      if nargin>2
        typecheck(contact_groups,'cell');
        sizecheck(contact_groups,length(obj.bodies));
        for i=1:length(obj.bodies)
          body = r.getBody(obj.bodies(i));
          body_groups = contact_groups{i};
          obj.contact_pts{i} = body.getTerrainContactPoints(body_groups);
          obj.contact_groups{i} = contact_groups{i};
          obj.num_contact_pts(i)=size(obj.contact_pts{i},2);
        end
      else
        % use all points on body
        for i=1:length(obj.bodies)
          terrain_contact_point_struct = getTerrainContactPoints(r,obj.bodies(i));
          obj.contact_pts{i} = terrain_contact_point_struct.pts;
          obj.contact_groups{i} = r.getBody(obj.bodies(i)).collision_geometry_group_names;
          obj.num_contact_pts(i)=size(obj.contact_pts{i},2);
        end
      end

      if nargin>3
        obj = setContactSurfaces(obj,contact_surfaces);
      else
        obj.contact_surfaces = zeros(length(obj.bodies),1);
      end
    end

    function obj = setContactSurfaces(obj,contact_surfaces)
      typecheck(contact_surfaces,'double');
      sizecheck(contact_surfaces,length(obj.bodies));
      obj.contact_surfaces = contact_surfaces;
    end

  end

end

